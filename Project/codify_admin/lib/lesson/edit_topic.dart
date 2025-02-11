import 'package:flutter/material.dart';
import 'topic.dart';
import 'topic_service.dart';

class EditTopicScreen extends StatefulWidget {
  final Topic topic;

  const EditTopicScreen({Key? key, required this.topic}) : super(key: key);

  @override
  _EditTopicScreenState createState() => _EditTopicScreenState();
}

class _EditTopicScreenState extends State<EditTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final TopicService _topicService = TopicService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.topic.name);
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
      );

      await _topicService.updateTopic(updatedTopic);
      Navigator.of(context).pop(updatedTopic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Topic'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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