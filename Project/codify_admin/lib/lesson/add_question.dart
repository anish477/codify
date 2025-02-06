import 'package:flutter/material.dart';
import 'question.dart';
import 'question_service.dart';

class AddQuestionScreen extends StatefulWidget {
  final String lessonId; // Lesson ID to associate the question with

  const AddQuestionScreen({Key? key, required this.lessonId}) : super(key: key);

  @override
  _AddQuestionScreenState createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionTextController = TextEditingController();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _feedbackController = TextEditingController();
  final _rewardsController = TextEditingController();
  final _optionsControllers = <TextEditingController>[
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  String _difficultyLevel = 'Easy';
  int _correctOption = 0;
  final QuestionService _questionService = QuestionService();

  @override
  void dispose() {
    _questionTextController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _feedbackController.dispose();
    _rewardsController.dispose();
    for (var controller in _optionsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Question'),
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
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Difficulty Level'),
                  value: _difficultyLevel,
                  items: ['Easy', 'Difficult', 'Hard'].map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _difficultyLevel = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a difficulty level';
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
                      return 'Please enter rewards';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
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
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Correct Option'),
                  value: _correctOption,
                  items: List.generate(
                    _optionsControllers.length,
                        (index) => DropdownMenuItem(
                      value: index,
                      child: Text('Option ${index + 1}'),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _correctOption = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select the correct option';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _addQuestion();
                    }
                  },
                  child: const Text('Add Question'),
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter option ${index + 1}';
            }
            return null;
          },
        ),
      );
    });
  }


  Future<void> _addQuestion() async {

      Question question = Question(
      title: _titleController.text,
      content: _contentController.text,
      difficulty: _difficultyLevel,
      rewards: int.parse(_rewardsController.text),
      questionText: _questionTextController.text,
      options: _optionsControllers.map((controller) => controller.text).toList(),
      correctOption: _correctOption,
      feedback: _feedbackController.text,
      lessonId: widget.lessonId,
    );

    await _questionService.createQuestion(question);
    if (mounted) {
      Navigator.of(context).pop();
    }

  }
}