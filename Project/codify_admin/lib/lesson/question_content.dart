import 'package:flutter/material.dart';
import 'question.dart';
import 'question_service.dart';
import 'add_question.dart';
import 'question_detail.dart';
import 'edit_question.dart';

class QuestionListScreen extends StatefulWidget {
  final String lessonId;

  const QuestionListScreen({super.key, required this.lessonId});

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
    List<Question> questions =
        await _questionService.getQuestionsForLesson(widget.lessonId);
    setState(() {
      _questions = questions;
    });
  }

  Future<void> _editQuestion(Question question) async {
    final updatedQuestion = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditQuestionScreen(question: question),
      ),
    );

    if (updatedQuestion != null) {
      setState(() {
        final index = _questions
            .indexWhere((q) => q.documentId == updatedQuestion.documentId);
        if (index != -1) {
          _questions[index] = updatedQuestion;
        }
      });
    }
  }

  Future<void> _deleteQuestion(String documentId) async {
    await _questionService.deleteQuestion(documentId);
    setState(() {
      _questions.removeWhere((question) => question.documentId == documentId);
    });
  }

  Future<void> _confirmDeleteQuestion(String documentId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          title: const Text('Delete Question'),
          content: const Text('Are you sure you want to delete this question?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      _deleteQuestion(documentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questions'),
        backgroundColor: const Color(0xFFFFFFFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          itemCount: _questions.length,
          itemBuilder: (context, index) {
            Question question = _questions[index];
            return Container(
              color: Colors.grey[200],
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(question.title),
                  subtitle: Text(question.questionText),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionDetailScreen(
                            documentId: question.documentId),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.blueAccent,
                        ),
                        onPressed: () => _editQuestion(question),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _confirmDeleteQuestion(question.documentId),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 8),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFFFFF),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddQuestionScreen(lessonId: widget.lessonId),
            ),
          ).then((_) => _fetchQuestions());
        },
        child: const Icon(Icons.add, color: Colors.blueAccent),
      ),
    );
  }
}
