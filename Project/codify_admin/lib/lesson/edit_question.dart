import 'package:flutter/material.dart';
import 'question.dart';
import 'question_service.dart';

class EditQuestionScreen extends StatefulWidget {
  final Question question;

  const EditQuestionScreen({Key? key, required this.question}) : super(key: key);

  @override
  _EditQuestionScreenState createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _difficultyController;
  late TextEditingController _rewardsController;
  late TextEditingController _feedbackController;
  late TextEditingController _questionTextController;
  late List<TextEditingController> _optionsControllers;
  late TextEditingController _correctOptionController;
  final QuestionService _questionService = QuestionService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.question.title);
    _contentController = TextEditingController(text: widget.question.content);
    _difficultyController = TextEditingController(text: widget.question.difficulty);
    _rewardsController = TextEditingController(text: widget.question.rewards.toString());
    _feedbackController = TextEditingController(text: widget.question.feedback);
    _questionTextController = TextEditingController(text: widget.question.questionText);
    _optionsControllers = widget.question.options.map((option) => TextEditingController(text: option)).toList();
    _correctOptionController = TextEditingController(text: widget.question.correctOption.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _difficultyController.dispose();
    _rewardsController.dispose();
    _feedbackController.dispose();
    _questionTextController.dispose();
    for (var controller in _optionsControllers) {
      controller.dispose();
    }
    _correctOptionController.dispose();
    super.dispose();
  }

  Future<void> _updateQuestion() async {
    if (_formKey.currentState!.validate()) {
      final updatedQuestion = widget.question.copyWith(
        title: _titleController.text,
        content: _contentController.text,
        difficulty: _difficultyController.text,
        rewards: int.parse(_rewardsController.text),
        feedback: _feedbackController.text,
        questionText: _questionTextController.text,
        options: _optionsControllers.map((controller) => controller.text).toList(),
        correctOption: int.parse(_correctOptionController.text),
      );

      await _questionService.updateQuestion(updatedQuestion.documentId, updatedQuestion);
      Navigator.of(context).pop(updatedQuestion);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Question'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the content';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _difficultyController,
                  decoration: const InputDecoration(labelText: 'Difficulty'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the difficulty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _rewardsController,
                  decoration: const InputDecoration(labelText: 'Rewards'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the rewards';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  maxLines:null,
                  keyboardType: TextInputType.multiline,
                  controller: _questionTextController,
                  decoration: const InputDecoration(labelText: 'Question Text'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the question text';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ..._buildOptionsFields(),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _feedbackController,
                  decoration: const InputDecoration(labelText: 'Feedback'),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _correctOptionController,
                  decoration: const InputDecoration(labelText: 'Correct Option (index)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the correct option index';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: _updateQuestion,
                  child: const Text('Update Question'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOptionsFields() {
    return List<Widget>.generate(_optionsControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: TextFormField(
          controller: _optionsControllers[index],
          decoration: InputDecoration(labelText: 'Option ${index + 1}'),
          // validator: (value) {
          //   if (value == null || value.isEmpty) {
          //     return 'Please enter option ${index + 1}';
          //   }
          //   return null;
          // },
        ),
      );
    });
  }
}