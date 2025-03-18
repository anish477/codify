import 'package:flutter/material.dart';
import 'lesson.dart';
import 'lesson_service.dart';

class AddLesson extends StatefulWidget {
  final String topicId;

  const AddLesson({super.key, required this.topicId});

  @override
  _AddLessonState createState() => _AddLessonState();
}

class _AddLessonState extends State<AddLesson> {
  final _formKey = GlobalKey<FormState>();
  final _questionNameController = TextEditingController();
  final LessonService _lessonService = LessonService();
  final _indexController = TextEditingController();

  @override
  void dispose() {
    _questionNameController.dispose();
    _indexController.dispose();
    super.dispose();
  }

  Future<void> _addLesson() async {
    if (_formKey.currentState!.validate()) {
      final newLesson = Lesson(
        documentId: '', // Firestore will generate the ID
        topicId: widget.topicId,
        questionName: _questionNameController.text,
        index: _indexController.text,
      );

      final createdLesson = await _lessonService.createLesson(newLesson);
      if (createdLesson != null) {
        Navigator.of(context).pop(createdLesson);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error creating lesson')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Lesson'),
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
                onPressed: _addLesson,
                child: const Text('Add Lesson'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}