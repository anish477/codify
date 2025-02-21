import 'package:codify/provider/lives_provider.dart';
import 'package:codify/provider/streak_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../widget/categoryWidget.dart';
import '../widget/showStreak.dart';
import 'user_lesson_content.dart';
import '../provider/lesson_provider.dart';
import 'package:codify/lesson/topic.dart';
import 'package:codify/lesson/lesson.dart';
import '../widget/buildLivesDisplay.dart';

class LessonMain extends StatefulWidget {
  const LessonMain({super.key});

  @override
  State<LessonMain> createState() => _LessonMainState();
}

class _LessonMainState extends State<LessonMain> {
  @override
  Widget build(BuildContext context) {
    final lessonProvider = Provider.of<LessonProvider>(context);
    final livesProvider = Provider.of<LivesProvider>(context);
    final streakProvider=Provider.of<StreakProvider>(context);
    final double panelHeight = lessonProvider.userLessons.length * 80.0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Text("${lessonProvider.selectedCategoryName}"),
            CategoryDisplay(),
            StreakDisplay(),
            // Container(
            //   child: Text("${streakProvider.lives}"),
            // ),
            BuildLivesDisplay(),
          ],
        ),
      ),
      body: lessonProvider.loading
          ? _buildLoadingUI()
          : lessonProvider.error != null
          ? _buildErrorUI(lessonProvider.error!)
          : lessonProvider.userLessons.isEmpty
          ? const Center(child: Text("No categories to display"))
          : _buildTopicAndLessonList(lessonProvider, livesProvider),
    );
  }

  Widget _buildLoadingUI() {
    return Center(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF78E08F),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 100,
                    height: 20,
                    color: Colors.grey[300],
                  ),
                  const Icon(Icons.arrow_downward, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorUI(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              "Error: $error",
              style: const TextStyle(color: Colors.red, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTopicAndLessonList(LessonProvider lessonProvider, LivesProvider livesProvider) {
    if (lessonProvider.topics.isEmpty) {
      return const Center(child: Text("No topics available."));
    }

    return ListView.builder(
      itemCount: lessonProvider.topics.length,
      itemBuilder: (context, index) {
        final Topic topic = lessonProvider.topics[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ExpansionTile(
            title: Text(topic.name),
            onExpansionChanged: (isExpanded) {
              if (isExpanded) {
                lessonProvider.selectTopic(topic.documentId);
              }
            },
            children: _buildLessonList(context, lessonProvider, topic, livesProvider),
          ),
        );
      },
    );
  }

  List<Widget> _buildLessonList(BuildContext context, LessonProvider lessonProvider, Topic topic, LivesProvider livesProvider) {
    List<Lesson> lessons = lessonProvider.lessons.where((lesson) => lesson.topicId == topic.documentId).toList();

    if (lessons.isEmpty) {
      return [const ListTile(title: Text("No lessons available."))];
    }

    return lessons.map((lesson) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          title: Text(lesson.questionName),
          onTap: () {
            if (livesProvider.lives?.currentLives == 0) {
              _showNoLivesDialog(context);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserLessonContent(documentId: lesson.documentId),
                ),
              );
            }
          },
        ),
      );
    }).toList();
  }

  void _showNoLivesDialog(context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Lives Left'),
          content: const Text('You have run out of lives. Please wait for them to refill.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}