import 'package:flutter/material.dart';
import 'lesson.dart';
import 'lesson_service.dart';

class EditLesson extends StatefulWidget {
  final Lesson lesson;

  const EditLesson({super.key, required this.lesson});

  @override
  _EditLessonState createState() => _EditLessonState();
}

class _EditLessonState extends State<EditLesson> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionNameController;
  final LessonService _lessonService = LessonService();
  late var _indexController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _questionNameController = TextEditingController(text: widget.lesson.questionName);
    _indexController= TextEditingController(text: widget.lesson.index);

  }

  @override
  void dispose() {
    _questionNameController.dispose();
    super.dispose();
  }

  Future<void> _updateLesson() async {
    if (_formKey.currentState!.validate()) {
      final updatedLesson = widget.lesson.copyWith(
        questionName: _questionNameController.text,
        index: _indexController.text,
      );

      await _lessonService.updateLesson(updatedLesson);
      Navigator.of(context).pop(updatedLesson);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Lesson'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _indexController,
                decoration: const InputDecoration(labelText: 'Index'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an index';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _questionNameController,
                decoration: const InputDecoration(labelText: 'Question Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a question name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateLesson,
                child: const Text('Update Lesson'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}