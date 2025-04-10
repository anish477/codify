import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../user/user_mistake.dart';
import '../user/user_mistake_service.dart';
import '../lesson/question_service.dart';
import '../lesson/question.dart';
import '../services/auth.dart';
import 'lesson_completed_page.dart';

class TrainingMistake extends StatefulWidget {
  const TrainingMistake({super.key});

  @override
  State<TrainingMistake> createState() => _TrainingMistakeState();
}

class _TrainingMistakeState extends State<TrainingMistake> {
  final UserMistakeService _userMistakeService = UserMistakeService();
  final QuestionService _questionService = QuestionService();
  final AuthService _auth = AuthService();
  List<UserMistake> _mistakes = [];
  bool _isLoading = true;
  int _currentMistakeIndex = 0;
  int _totalAttempts = 0;
  int _correctAnswers = 0;
  DateTime _startTime = DateTime.now();

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

  Future<void> _checkAnswer(int selectedOption, Question question) async {
    bool isCorrectAnswer = question.correctOption == selectedOption;
    _totalAttempts++;

    if (isCorrectAnswer) {
      final Duration timeSpent = DateTime.now().difference(_startTime);
      final double accuracy = _totalAttempts > 0
          ? (_correctAnswers / _totalAttempts) * 100
          : 100.0;
      setState(() {
        _userMistakeService.deleteUserMistake(question.documentId);
        _mistakes.removeAt(_currentMistakeIndex);
        if(_mistakes.isEmpty){
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => LessonCompletedPage(
                    pointsEarned: _correctAnswers * 5,
                    lessonId: 'mistakes-training',
                    timeToComplete: timeSpent,
                    accuracy: accuracy,
                  )
              )
          );
          return;
        }
        if (_currentMistakeIndex >= _mistakes.length) {
          _currentMistakeIndex = 0;
        }
      });
    } else {
      final user = await _auth.getUID();
      if (user != null) {
        _userMistakeService.createUserMistake(UserMistake(
          userId: user,
          mistake: question.documentId,
        ));
      }
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Mistakes'),
      ),
      body: _isLoading
          ? Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 100.0,
          color: Colors.white,
        ),
      )
          : _mistakes.isEmpty
          ? const Center(child: Text('No mistakes found'))
          : FutureBuilder<Question?>(
        future: fetchQuestion(_mistakes[_currentMistakeIndex].mistake),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Card(
                child: ListTile(
                  title: Container(
                    height: 20,
                    color: Colors.white,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(4, (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Container(
                        height: 20,
                        color: Colors.white,
                      ),
                    )),
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return const Text('Error loading question');
          } else if (!snapshot.hasData) {
            return const Text('Question not found');
          } else {
            final question = snapshot.data!;
            return Card(
              child: ListTile(
                title: Text(question.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(question.content),
                    const SizedBox(height: 8),
                    Text('Question: ${question.questionText}'),
                    const SizedBox(height: 8),
                    Text('Options:'),
                    ...question.options.asMap().entries.map((entry) {
                      int idx = entry.key;
                      String option = entry.value;
                      return ListTile(
                        title: Text(option),
                        onTap: () => _checkAnswer(idx, question),
                      );
                    }),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}