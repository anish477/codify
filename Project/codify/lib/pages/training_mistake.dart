import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../user/user_mistake.dart';
import '../user/user_mistake_service.dart';
import '../lesson/question_service.dart';
import '../lesson/question.dart';
import '../services/auth.dart';

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
    if (isCorrectAnswer) {
      setState(() {
        if (_currentMistakeIndex < _mistakes.length - 1) {
          _currentMistakeIndex++;
        } else {
          Navigator.pop(context);
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCorrectAnswer ? 'Correct!' : 'Incorrect!'),
          content: Text(
            isCorrectAnswer
                ? 'Well done!'
                : 'Incorrect answer, try again!\nFeedback: ${question.feedback}',
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
        child: Text(''),
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