import 'package:flutter/material.dart';
import 'topic.dart';
import 'topic_service.dart';

class AddTopicScreen extends StatefulWidget {
  final String categoryId;

  const AddTopicScreen({Key? key, required this.categoryId}) : super(key: key);

  @override
  _AddTopicScreenState createState() => _AddTopicScreenState();
}

class _AddTopicScreenState extends State<AddTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final TopicService _topicService = TopicService();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addTopic() async {
    if (_formKey.currentState!.validate()) {
      final newTopic = Topic(
        documentId: '', // Firestore will generate the ID
        name: _nameController.text,
        categoryId: widget.categoryId,
        lessonIds: [],
      );

      final createdTopic = await _topicService.createTopic(newTopic);
      if (createdTopic != null) {
        Navigator.of(context).pop(createdTopic);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error creating topic')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Topic'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Topic Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a topic name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addTopic,
                child: const Text('Add Topic'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}