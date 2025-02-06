import 'package:flutter/material.dart';

import 'lesson.dart';
import 'lesson_service.dart';
import 'question_content.dart';

class TopicContent extends StatefulWidget {
  final String topicId;

  const TopicContent({super.key, required this.topicId});

  @override
  State<TopicContent> createState() => _TopicContentState();
}

class _TopicContentState extends State<TopicContent> {
  final LessonService _lessonService = LessonService();
  List<Lesson> _lessons = [];

  @override
  void initState() {
    super.initState();
    _fetchLessons();
  }

  Future<void> _fetchLessons() async {
    final lessons = await _lessonService.getLessonsByTopicId(widget.topicId);
    setState(() {
      _lessons = lessons;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topic Content'),
      ),
      body: ListView.separated(

        itemCount: _lessons.length,
        itemBuilder: (context, index) {
          return Container(
            color: Colors.grey[200],
            child: ListTile(

              title: Text(_lessons[index].questionName),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionListScreen(lessonId: _lessons[index].documentId),
                  ),
                );
              },
            ),
          );
        },

        separatorBuilder: (context, index) => const SizedBox(height: 8),
      ),

    );
  }
}