import 'package:codify/pages/badge_provider.dart';
import 'package:codify/pages/lesson_completed_page.dart';
import 'package:codify/provider/leaderboard_provider.dart';
import 'package:codify/provider/lives_provider.dart';
import 'package:codify/provider/profile_provider.dart';
import 'package:codify/provider/user_stat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/python.dart';
import '../gamification/leaderboard.dart';
import '../lesson/question.dart';
import '../lesson/question_service.dart';
import '../provider/streak_provider.dart';
import '../user/user_mistake.dart';
import '../user/user_mistake_service.dart';
import '../services/auth.dart';
import '../gamification/leaderboard_service.dart';
import '../gamification/lives_service.dart';
import '../gamification/lives.dart';
import '../gamification/badge_service.dart';
import '../lesson/lesson_service.dart';

class UserLessonContent extends StatefulWidget {
  final String documentId;
  final String topicId;

  const UserLessonContent(
      {super.key, required this.documentId, required this.topicId});

  @override
  State<UserLessonContent> createState() => _UserLessonContentState();
}

class _UserLessonContentState extends State<UserLessonContent> {
  final QuestionService _questionService = QuestionService();
  final UserMistakeService _userMistakeService = UserMistakeService();
  final AuthService _auth = AuthService();
  final LeaderboardService _leaderboardService = LeaderboardService();
  final LivesService _livesService = LivesService();
  bool _isSubmittingFinal = false;

  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isCorrectAnswer = false;
  bool _isLoading = true;
  int lessonPoints = 0;
  Lives? _lives;

  DateTime _lessonStartTime = DateTime.now();
  int _correctAnswers = 0;
  int _totalAttempts = 0;

  @override
  void initState() {
    super.initState();
    _lessonStartTime = DateTime.now();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final user = await _auth.getUID();
    if (user != null) {
      await _livesService.init(user);
      _lives = _livesService.getLives();
    }
    await _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final questions =
          await _questionService.getQuestionsForLesson(widget.documentId);
      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching questions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkAnswer(int selectedOption) async {
    setState(() {
      _totalAttempts++;
    });

    if (_questions[_currentQuestionIndex].correctOption == selectedOption) {
      setState(() {
        _isCorrectAnswer = true;
        lessonPoints += _questions[_currentQuestionIndex].rewards;
        _correctAnswers++;
      });

      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
        });
      } else {
        setState(() {
          _isSubmittingFinal = true;
        });

        final String? user = await _auth.getUID();
        if (user != null) {
          try {
            await _leaderboardService.addLeaderboardEntry(Leaderboard(
              userId: user,
              points: lessonPoints,
              timestamp: DateTime.now(),
              documentId: '',
            ));

            await Provider.of<StreakProvider>(context, listen: false)
                .updateStreak();
            final userStatProvider =
                Provider.of<UserStatProvider>(context, listen: false);
            await userStatProvider.markQuestionAsComplete(
                user, widget.topicId, widget.documentId);

            final badgeService = BadgeService();
            await badgeService.awardFirstLessonBadge(user, widget.topicId);

            final lessonService = LessonService();
            final lessons =
                await lessonService.getLessonsByTopicId(widget.topicId);
            bool allMastered = true;
            for (var lesson in lessons) {
              final qs = await _questionService
                  .getQuestionsForLesson(lesson.documentId);
              for (var q in qs) {
                if (!userStatProvider.questionIds.contains(q.documentId)) {
                  allMastered = false;
                  break;
                }
              }
              if (!allMastered) break;
            }
            if (allMastered) {
              await badgeService.awardTopicMasteryBadge(user, widget.topicId);
            }

            double accuracy = _totalAttempts > 0
                ? (_correctAnswers / _totalAttempts) * 100.0
                : 0.0;

            await Provider.of<LeaderboardProvider>(context, listen: false)
                .refreshLeaderboard();
            await Provider.of<ProfileProvider>(context, listen: false)
                .refreshProfile();

            if (mounted) {
              setState(() {
                _isSubmittingFinal = false;
              });

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LessonCompletedPage(
                          pointsEarned: lessonPoints,
                          lessonId: widget.documentId,
                          timeToComplete:
                              DateTime.now().difference(_lessonStartTime),
                          accuracy: accuracy,
                          newStreak: Provider.of<StreakProvider>(context,
                                  listen: false)
                              .streak
                              ?.currentStreak,
                          newBadge:
                              Provider.of<BadgeProvider>(context, listen: false)
                                      .badges
                                      .isNotEmpty
                                  ? Provider.of<BadgeProvider>(context,
                                          listen: false)
                                      .badges
                                      .last
                                      .name
                                  : null)));
            }
          } catch (e) {
            print('Error completing lesson: $e');
            if (mounted) {
              setState(() {
                _isSubmittingFinal = false;
              });
            }
          }
        }
        return;
      }
    } else {
      if (_lives != null) {
        final livesProvider =
            Provider.of<LivesProvider>(context, listen: false);
        livesProvider.decreaseLives();
        _lives = _livesService.getLives();
        if (livesProvider.lives?.currentLives == 0) {
          Future.delayed(Duration(milliseconds: 300), _showNoLivesDialog);
          return;
        }
      }
      setState(() {
        _isCorrectAnswer = false;
      });
      final user = await _auth.getUID();
      if (user != null) {
        _userMistakeService.createUserMistake(UserMistake(
          userId: user,
          mistake: _questions[_currentQuestionIndex].documentId,
        ));
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFFFFFFF),
          title: _isCorrectAnswer
              ? const Text('Correct!',
                  style: TextStyle(color: Color.fromARGB(255, 21, 216, 14)))
              : const Text('Incorrect!', style: TextStyle(color: Colors.red)),
          content: _isCorrectAnswer
              ? const Text('Great job!',
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold))
              : Text(
                  'Feedback:\n${_questions[_currentQuestionIndex].feedback}',
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500),
                ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK',
                  style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF00C7BE),
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showNoLivesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFFFFFFF),
          title: const Text(
            'No Lives Left',
            style: TextStyle(color: Colors.red),
          ),
          content: const Text(
              'You have run out of lives. Please wait for them to refill.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final livesProvider = Provider.of<LivesProvider>(context);
    double progress = _questions.isNotEmpty
        ? (_currentQuestionIndex + 1) / _questions.length
        : 0.0;

    Widget mainContent = Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFFFFFF),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: LinearProgressIndicator(
                value: progress,
                borderRadius: BorderRadius.circular(10),
                backgroundColor: Colors.grey[300],
                minHeight: 15,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF00C7BE)),
              ),
            ),
            const SizedBox(width: 19),
            Row(
              children: [
                Text(
                  '${livesProvider.lives?.currentLives ?? 0}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 5),
                const Icon(Icons.favorite, color: Colors.red),
                const SizedBox(width: 8)
              ],
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: _isLoading
          ? Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    height: 100,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          : _questions.isEmpty
              ? const Center(child: Text('No questions found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _questions[_currentQuestionIndex].title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _questions[_currentQuestionIndex].content,
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Code Editor
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CodeTheme(
                          data: CodeThemeData(styles: monokaiSublimeTheme),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                CodeField(
                                    controller: CodeController(
                                      text: _questions[_currentQuestionIndex]
                                          .questionText,
                                      language: python,
                                    ),
                                    gutterStyle: const GutterStyle(
                                      showLineNumbers: false,
                                    ),
                                    readOnly: true,
                                    textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'RobotoMono')),
                              ]),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Expanded(
                        child: ListView.builder(
                          itemCount:
                              _questions[_currentQuestionIndex].options.length,
                          itemBuilder: (context, index) {
                            final option = _questions[_currentQuestionIndex]
                                .options[index];
                            return Card(
                              child: ListTile(
                                title: Text(option,
                                    style: const TextStyle(fontSize: 16)),
                                onTap: () => _checkAnswer(index),
                                tileColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );

    return Stack(
      children: [
        mainContent,
        if (_isSubmittingFinal)
          Container(
            color: Colors.black54,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(
                      color: Color(0xFF1cb0f6),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
