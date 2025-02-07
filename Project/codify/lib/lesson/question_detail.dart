import 'package:flutter/material.dart';
import 'question.dart';
import 'question_service.dart';

class QuestionDetailScreen extends StatefulWidget {
  final String documentId;

  const QuestionDetailScreen({super.key, required this.documentId});

  @override
  _QuestionDetailScreenState createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  final QuestionService _questionService = QuestionService();
  Question? _question;

  @override
  void initState() {
    super.initState();
    _fetchQuestionDetails();
  }

  Future<void> _fetchQuestionDetails() async {
    try {
      Question? question = await _questionService.getQuestionById(widget.documentId);
      setState(() {
        _question = question;
      });
    } catch (e) {
      print('Error fetching question details: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching question details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_question == null) {
      return const Scaffold(
        body: Center(child: Text('No question found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_question!.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Content: ${_question!.content}'),
            Text('Difficulty: ${_question!.difficulty}'),
            Text('Rewards: ${_question!.rewards}'),
            Text('Question Text: ${_question!.questionText}'),
            // Display options
            ..._question!.options.map((option) => Text('Option: $option')),
            Text('Correct Option: Option ${_question!.correctOption + 1}'),
            Text('Feedback: ${_question!.feedback}'),
          ],
        ),
      ),
    );
  }
}