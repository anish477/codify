import 'package:flutter/material.dart';
import 'lesson.dart';
import 'lesson_service.dart';

<<<<<<< HEAD
class AddLesson extends StatefulWidget {
  final String topicId;

  const AddLesson({super.key, required this.topicId});
=======
class AddLessonScreen extends StatefulWidget {
  final String topicId;

  const AddLessonScreen({Key? key, required this.topicId}) : super(key: key);
>>>>>>> f0a891753fed7f6034e8d59a3330b7187acbf294

  @override
  _AddLessonScreenState createState() => _AddLessonScreenState();
}

<<<<<<< HEAD
class _AddLessonScreenState extends State<AddLesson> {
=======
class _AddLessonScreenState extends State<AddLessonScreen> {
>>>>>>> f0a891753fed7f6034e8d59a3330b7187acbf294
  final _formKey = GlobalKey<FormState>();
  final _questionNameController = TextEditingController();
  final LessonService _lessonService = LessonService();

  @override
  void dispose() {
    _questionNameController.dispose();
    super.dispose();
  }

  Future<void> _addLesson() async {
    if (_formKey.currentState!.validate()) {
      final newLesson = Lesson(
<<<<<<< HEAD
        documentId: '',
=======
        documentId: '', // Firestore will generate the ID
>>>>>>> f0a891753fed7f6034e8d59a3330b7187acbf294
        topicId: widget.topicId,
        questionName: _questionNameController.text,
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
                controller: _questionNameController,
<<<<<<< HEAD
                decoration: const InputDecoration(labelText: 'Lesson Name'),
=======
                decoration: const InputDecoration(labelText: 'Question Name'),
>>>>>>> f0a891753fed7f6034e8d59a3330b7187acbf294
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