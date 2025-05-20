import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/python.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestionDetails();
  }

  Future<void> _fetchQuestionDetails() async {
    try {
      Question? question =
          await _questionService.getQuestionById(widget.documentId);
      setState(() {
        _question = question;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching question details: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching question details')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: Text(
                _question?.title ?? '',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _question == null
              ? const Center(child: Text('No question found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      Text(
                        'Content: ${_question!.content}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Difficulty: ${_question!.difficulty}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rewards: ${_question!.rewards}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),

                      _question!.questionText.isNotEmpty
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: CodeTheme(
                                data:
                                    CodeThemeData(styles: monokaiSublimeTheme),
                                child: CodeField(
                                  controller: CodeController(
                                    text: _question!.questionText,
                                    language: python,
                                  ),
                                  gutterStyle:
                                      const GutterStyle(showLineNumbers: false),
                                  readOnly: true,
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'RobotoMono',
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(height: 8),
                      Text(
                        'Correct Option: Option ${_question!.correctOption + 1}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Feedback: ${_question!.feedback}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      // Display options
                      ..._question!.options.map(
                        (option) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              tileColor: const Color(0xFFFFFFFF),
                              title: Text(option,
                                  style: const TextStyle(fontSize: 16)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
