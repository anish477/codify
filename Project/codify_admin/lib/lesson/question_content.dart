import 'package:flutter/material.dart';
import 'question.dart';
import 'question_service.dart';
import 'add_question.dart';
import 'question_detail.dart';

class QuestionListScreen extends StatefulWidget {
  final String lessonId;

  const QuestionListScreen({Key? key, required this.lessonId}) : super(key: key);

  @override
  _QuestionListScreenState createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  final QuestionService _questionService = QuestionService();
  List<Question> _questions = [];

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    List<Question> questions = await _questionService.getQuestionsForLesson(widget.lessonId);
    setState(() {
      _questions = questions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questions'),
      ),
      body: ListView.separated(
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          Question question = _questions[index];
          return Container(
            color: Colors.grey[200],
            child: ListTile(
              title: Text(question.title),
              subtitle: Text(question.questionText),

              onTap: () {

                Navigator.push(
                  context,MaterialPageRoute(builder: (context) => QuestionDetailScreen(documentId: _questions[index].documentId,)),
                );
              },
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 8),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddQuestionScreen(lessonId: widget.lessonId),
            ),
          ).then((_) => _fetchQuestions());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}