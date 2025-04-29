import 'package:codify_admin/lesson/topic_content.dart';
import 'package:flutter/material.dart';
import 'topic.dart';
import 'topic_service.dart';
import 'category.dart';
import 'add_topic.dart';
import 'edit_topic.dart';

class TopicList extends StatefulWidget {
  final Category category;

  const TopicList({super.key, required this.category});

  @override
  _TopicListState createState() => _TopicListState();
}

class _TopicListState extends State<TopicList> {
  final TopicService _topicService = TopicService();
  List<Topic> _topics = [];

  @override
  void initState() {
    super.initState();
    _fetchTopics();
  }

  Future<void> _fetchTopics() async {
    final topics = await _topicService.getAllTopics();
    setState(() {
      _topics = topics
          .where((topic) => topic.categoryId == widget.category.documentId)
          .toList();
    });
  }

  Future<void> _addTopic() async {
    final newTopic = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AddTopicScreen(categoryId: widget.category.documentId),
      ),
    );

    if (newTopic != null) {
      setState(() {
        _topics.add(newTopic);
      });
    }
  }

  Future<void> _editTopic(Topic topic) async {
    final updatedTopic = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTopicScreen(topic: topic),
      ),
    );

    if (updatedTopic != null) {
      setState(() {
        final index =
            _topics.indexWhere((t) => t.documentId == updatedTopic.documentId);
        if (index != -1) {
          _topics[index] = updatedTopic;
        }
      });
    }
  }

  Future<void> _confirmDeleteTopic(String documentId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          title: const Text('Delete Topic'),
          content: const Text('Are you sure you want to delete this topic?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteTopic(documentId);
    }
  }

  Future<void> _deleteTopic(String documentId) async {
    await _topicService.deleteTopic(documentId);
    setState(() {
      _topics.removeWhere((topic) => topic.documentId == documentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: Text('Topics in ${widget.category.name}'),
        backgroundColor: const Color(0xFFFFFFFF),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: ListView.separated(
                  itemCount: _topics.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 5,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(_topics[index].name),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TopicContent(
                                  topicId: _topics[index].documentId),
                            ),
                          );
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.blueAccent),
                              onPressed: () => _editTopic(_topics[index]),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDeleteTopic(
                                  _topics[index].documentId),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFFFFF),
        onPressed: _addTopic,
        child: const Icon(
          Icons.add,
          color: Colors.blue,
        ),
      ),
    );
  }
}
