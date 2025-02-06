
import 'package:codify/lesson/topic_content.dart';
import 'package:flutter/material.dart';
import 'topic.dart';
import 'topic_service.dart';
import 'category.dart';


class TopicList extends StatefulWidget {
  final Category category;

  const TopicList({super.key, required this.category, required lesson});

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
      _topics = topics.where((topic) => topic.categoryId == widget.category.documentId).toList();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Topics in ${widget.category.name}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: _topics.length,
              itemBuilder: (context, index) {
                return Container(

                  color: Colors.grey[200],
                  // Background color for each item
                  child: ListTile(
                    title: Text(_topics[index].name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TopicContent( topicId: _topics[index].documentId),
                        ),
                      );
                    },
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 8), // Separator between items
            ),
          ),
        ],
      ),

    );
  }
}