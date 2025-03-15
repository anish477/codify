import 'package:codify/provider/lives_provider.dart';
import 'package:codify/provider/streak_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../widget/categoryWidget.dart';
import '../widget/showStreak.dart';
import 'user_lesson_content.dart';
import '../provider/lesson_provider.dart';
import '../provider/user_stat_provider.dart';
import 'package:codify/lesson/topic.dart';
import 'package:codify/lesson/lesson.dart';
import '../widget/buildLivesDisplay.dart';
import '../services/auth.dart';
import 'package:intl/intl.dart';

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
    final streakProvider = Provider.of<StreakProvider>(context);
    final userStatProvider = Provider.of<UserStatProvider>(context); // Get UserStatProvider here

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CategoryDisplay(),
            StreakDisplay(),
            BuildLivesDisplay(),
          ],
        ),
      ),
      backgroundColor: Color(0xFFFFFFFF),
      body: lessonProvider.loading
          ? _buildLoadingUI()
          : lessonProvider.error != null
          ? _buildErrorUI(lessonProvider.error!)
          : lessonProvider.userLessons.isEmpty
          ? const Center(child: Text("No categories to display"))
          : _buildTopicAndLessonList(lessonProvider, livesProvider, userStatProvider), // Pass userStatProvider
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

  Widget _buildTopicAndLessonList(LessonProvider lessonProvider, LivesProvider livesProvider, UserStatProvider userStatProvider) { // Receive userStatProvider
    if (lessonProvider.topics.isEmpty) {
      return const Center(child: Text("No topics available."));
    }

    return ListView.builder(
      itemCount: lessonProvider.topics.length,
      itemBuilder: (context, index) {
        final Topic topic = lessonProvider.topics[index];
        return Container(
          width: 400,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topic Container
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    padding: EdgeInsets.all(12),
                    color: Color(0xFFFDB813),
                    width: constraints.maxWidth * 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(topic.name, style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Introduction', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              //Lesson Content
              _buildLessonList(context, lessonProvider, topic, livesProvider, userStatProvider), // Pass userStatProvider
            ],
          ),
        );
      },
    );
  }

  Widget _buildLessonList(BuildContext context, LessonProvider lessonProvider, Topic topic, LivesProvider livesProvider, UserStatProvider userStatProvider) { // Receive userStatProvider
    List<Lesson> lessons = lessonProvider.lessons.where((lesson) => lesson.topicId == topic.documentId).toList();

    // lessons.sort((a, b) {
    //   if (a.createdAt == null && b.createdAt == null) return 0;
    //   if (a.createdAt == null) return 1;
    //   if (b.createdAt == null) return -1;
    //   return a.createdAt!.compareTo(b.createdAt!);
    // });

    List<Widget> lessonWidgets = [];

    for (int i = 0; i < lessons.length; i++) {
      Lesson lesson = lessons[i];
      bool isLastLesson = i == lessons.length - 1;
      bool isLessonUnlocked = true;  // Assume lesson is unlocked by default

      //
      if (i > 0) {
        Lesson previousLesson = lessons[i - 1];
        if (!userStatProvider.questionIds.contains(previousLesson.documentId)) {
          isLessonUnlocked = false;
        }
      }

      lessonWidgets.add(
        Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                _circleIcon(
                  Icons.play_circle_fill,
                  isLessonUnlocked ? Colors.orange : Colors.grey,  // Change color based on lock status
                  onTap: isLessonUnlocked
                      ? () async {
                    final userId = await AuthService().getUID();

                    if (userStatProvider.questionIds.contains(lesson.documentId)) {
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
                    } else {
                      _showLockedLessonDialog(context);
                    }
                  }
                      : null, // Disable onTap if locked
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              lesson.questionName,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isLessonUnlocked ? Colors.black : Colors.grey), // Grey out the text
            ),
          ],
        ),
      );

      if (!isLastLesson) {
        lessonWidgets.add(
          SizedBox(height: 32),
        );
        lessonWidgets.add(
          Row(
            children: [
              SizedBox(width: 36),
              _verticalLine(isLessonUnlocked),  // Change line color based on current lesson status
            ],
          ),
        );
      }
    }

    return Column(
      children: lessonWidgets,
    );
  }

  // Circle Icon Widget
  Widget _circleIcon(IconData icon, Color bgColor, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  // Vertical Line
  Widget _verticalLine(bool isUnlocked) {  // Added parameter
    return Container(
      width: 2,
      height: 32,
      color: isUnlocked ? Colors.grey[400] : Colors.grey[700],  // Change color based on status
      margin: EdgeInsets.only(right: 8),
    );
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

  void _showLockedLessonDialog(context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lesson Locked'),
          content: const Text('You need to complete the previous lessons to unlock this one.'),
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