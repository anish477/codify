import 'package:codify/pages/lesson_completed_page.dart';
import 'package:codify/provider/lives_provider.dart';
import 'package:codify/widget/buildLivesDisplay.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../gamification/leaderboard.dart';
import '../lesson/question.dart';
import '../lesson/question_service.dart';
import '../provider/lesson_provider.dart';
import '../user/user_mistake.dart';
import '../user/user_mistake_service.dart';
import '../services/auth.dart';
import '../gamification/leaderboard_service.dart';
import '../gamification/streak_service.dart';
import '../gamification/lives_service.dart';
import '../gamification/lives.dart';

class UserLessonContent extends StatefulWidget {
  final String documentId;
  const UserLessonContent({super.key, required this.documentId});

  @override
  State<UserLessonContent> createState() => _UserLessonContentState();
}

class _UserLessonContentState extends State<UserLessonContent> {
  final QuestionService _questionService = QuestionService();
  final UserMistakeService _userMistakeService = UserMistakeService();
  final AuthService _auth = AuthService();
  final LeaderboardService _leaderboardService = LeaderboardService();
  final StreakService _streakService = StreakService();
  final LivesService _livesService = LivesService();
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isCorrectAnswer = false;
  bool _showFeedback = false;
  bool _isLoading = true;
  int lessonPoints = 0;
  Lives? _lives;

  @override
  void initState() {
    super.initState();
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
      final questions = await _questionService.getQuestionsForLesson(widget.documentId);
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
    if (_questions[_currentQuestionIndex].correctOption == selectedOption) {
      setState(() {
        _isCorrectAnswer = true;
        _showFeedback = true;
      });
      lessonPoints += _questions[_currentQuestionIndex].rewards;
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
        });
      } else {
        final String? user = await _auth.getUID();
        if (user != null) {
          await _leaderboardService.addLeaderboardEntry(Leaderboard(
            userId: user,
            points: lessonPoints,
            timestamp: DateTime.now(),
            documentId: '',
          ));
          await _streakService.updateStreak(user);
        }
        Navigator.push(context, MaterialPageRoute(builder: (context) => LessonCompletedPage()));
      }
    } else {
      if (_lives != null) {
        final livesProvider = Provider.of<LivesProvider>(context, listen: false);
        livesProvider.decreaseLives();
        _lives = _livesService.getLives();
        if (livesProvider.lives?.currentLives == 0) {
          _showNoLivesDialog();
          return;
        }
      }
      setState(() {
        _isCorrectAnswer = false;
        _showFeedback = true;
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
          title: Text(_isCorrectAnswer ? 'Correct!' : 'Incorrect!'),
          content: Text(
            _isCorrectAnswer
                ? 'Well done!'
                : 'Incorrect answer, try again!\nFeedback: ${_questions[_currentQuestionIndex].feedback}',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
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
          title: const Text('No Lives Left'),
          content: const Text('You have run out of lives. Please wait for them to refill.'),
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
    final lessonProvider = Provider.of<LessonProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Lesson Content'),
      ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BuildLivesDisplay(),
            Text(
              _questions[_currentQuestionIndex].title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _questions[_currentQuestionIndex].content,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Question: ${_questions[_currentQuestionIndex].questionText}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Options:',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ..._questions[_currentQuestionIndex].options.asMap().entries.map((entry) {
              int idx = entry.key;
              String option = entry.value;
              return ListTile(
                title: Text(option),
                onTap: () => _checkAnswer(idx),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}