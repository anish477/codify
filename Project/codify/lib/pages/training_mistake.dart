import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/python.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import '../user/user_mistake.dart';
import '../user/user_mistake_service.dart';
import '../lesson/question_service.dart';
import '../lesson/question.dart';
import '../services/auth.dart';
import '../provider/lives_provider.dart';
import 'lesson_completed_page.dart';
import 'package:provider/provider.dart';

class TrainingMistake extends StatefulWidget {
  const TrainingMistake({super.key});

  @override
  State<TrainingMistake> createState() => _TrainingMistakeState();
}

class _TrainingMistakeState extends State<TrainingMistake> {
  final UserMistakeService _userMistakeService = UserMistakeService();
  final QuestionService _questionService = QuestionService();
  final AuthService _auth = AuthService();
  final LivesProvider livesProvider = LivesProvider();
  List<UserMistake> _mistakes = [];
  bool _isLoading = true;
  int _currentMistakeIndex = 0;
  int _totalAttempts = 0;
  int _correctAnswers = 0;
  final DateTime _startTime = DateTime.now();
  final bool _isSubmittingFinal = false;
  final DateTime _lessonStartTime = DateTime.now();

  final Map<String, Question> _questionCache = {};

  @override
  void initState() {
    super.initState();
    fetchMistakes();
  }

  Future<void> fetchMistakes() async {
    try {
      final userId = await _auth.getUID();
      final mistakes = await _userMistakeService.getUserMistakes(userId!);
      if (mounted) {
        setState(() {
          _mistakes = mistakes;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching mistakes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Question?> fetchQuestion(String questionId) async {
    try {
      return await _questionService.getQuestionById(questionId);
    } catch (e) {
      print('Error fetching question: $e');
      return null;
    }
  }

  Future<void> _checkAnswer(int selectedOption) async {
    setState(() {
      _totalAttempts++;
    });

    final questionId = _mistakes[_currentMistakeIndex].mistake;
    Question? question;

    if (_questionCache.containsKey(questionId)) {
      question = _questionCache[questionId];
    } else {
      question = await fetchQuestion(questionId);
      if (question != null) {
        _questionCache[questionId] = question;
      }
    }

    if (question == null) return;

    bool isCorrectAnswer = question.correctOption == selectedOption;

    if (isCorrectAnswer) {
      setState(() {
        _correctAnswers++;
      });

      final Duration timeSpent = DateTime.now().difference(_startTime);
      final double accuracy =
          _totalAttempts > 0 ? (_correctAnswers / _totalAttempts) * 100 : 100.0;

      final mistakeToDelete = _mistakes[_currentMistakeIndex].mistake;

      await _userMistakeService.deleteUserMistake(mistakeToDelete);

      setState(() {
        _mistakes.removeAt(_currentMistakeIndex);

        if (_mistakes.isEmpty) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => LessonCompletedPage(
                        pointsEarned: _correctAnswers * 5,
                        lessonId: 'mistakes-training',
                        timeToComplete: timeSpent,
                        accuracy: accuracy,
                      )));
          return;
        }

        if (_currentMistakeIndex >= _mistakes.length) {
          _currentMistakeIndex = 0;
        }
      });
    } else {
      final livesProvider = Provider.of<LivesProvider>(context, listen: false);
      livesProvider.decreaseLives();
      if (livesProvider.lives?.currentLives == 0) {
        Future.delayed(const Duration(milliseconds: 300), _showNoLivesDialog);
        return;
      }

      final user = await _auth.getUID();
      if (user != null) {
        await _userMistakeService.createUserMistake(UserMistake(
          userId: user,
          mistake: question.documentId,
        ));
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Incorrect!', style: TextStyle(color: Colors.red)),
          content: Text(
            'Feedback:\n${question?.feedback}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          actions: [
            TextButton(
              child: const Text('OK',
                  style: TextStyle(
                    color: Color(0xFF00C7BE),
                    fontWeight: FontWeight.bold,
                  )),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = _mistakes.isNotEmpty
        ? (_currentMistakeIndex + 1) / _mistakes.length
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
                Navigator.of(context).pop();
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
          : _mistakes.isEmpty
              ? const Center(child: Text('No questions found'))
              : FutureBuilder<Question?>(
                  future:
                      fetchQuestion(_mistakes[_currentMistakeIndex].mistake),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final question = snapshot.data!;
                    return Padding(
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
                                  question.title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  question.content,
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
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
                                          text: question.questionText,
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
                              itemCount: question.options.length,
                              itemBuilder: (context, index) {
                                final option = question.options[index];
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
                    );
                  }),
    );

    return Stack(
      children: [
        mainContent,
        if (_isSubmittingFinal)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF1cb0f6)),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showNoLivesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('No Lives Left', style: TextStyle(color: Colors.red)),
        content: const Text(
            'You have run out of lives. Please wait for them to refill.'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }
}
