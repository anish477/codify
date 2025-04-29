import 'package:flutter/material.dart';
import 'topic.dart';
import 'topic_service.dart';

class EditTopicScreen extends StatefulWidget {
  final Topic topic;

  const EditTopicScreen({super.key, required this.topic});

  @override
  _EditTopicScreenState createState() => _EditTopicScreenState();
}

class _EditTopicScreenState extends State<EditTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final TopicService _topicService = TopicService();
  final _indexController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.topic.name);
    _indexController.text = widget.topic.index;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateTopic() async {
    if (_formKey.currentState!.validate()) {
      final updatedTopic = widget.topic.copyWith(
        name: _nameController.text,
        index: _indexController.text,
      );

      await _topicService.updateTopic(updatedTopic);
      Navigator.of(context).pop(updatedTopic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('Edit Topic'),
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
                    return 'Please enter the name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                ),
                onPressed: _updateTopic,
                child: const Text('Update Topic'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
