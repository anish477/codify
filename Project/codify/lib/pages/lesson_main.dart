
import 'package:codify/provider/lives_provider.dart';
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

class LessonMain extends StatefulWidget {
  const LessonMain({super.key});

  @override
  State<LessonMain> createState() => _LessonMainState();
}

class _LessonMainState extends State<LessonMain> {
  String? _userId;
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _userId = await AuthService().getUID();
    if (_userId != null) {
      setState(() => _loadingUser = false);
    } else {
      // Handle case when user Id could not be loaded
      setState(() => _loadingUser = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessonProvider = Provider.of<LessonProvider>(context);
    final livesProvider = Provider.of<LivesProvider>(context);
    final userStatProvider = Provider.of<UserStatProvider>(context);


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const CategoryDisplay(),
            const StreakDisplay(),
            const BuildLivesDisplay(),
          ],
        ),
      ),
      backgroundColor: Color(0xFFFFFFFF),
      body: _loadingUser
          ? const Center(child: CircularProgressIndicator())
          : lessonProvider.loading
          ? _buildLoadingUI()
          : lessonProvider.error != null
          ? _buildErrorUI(lessonProvider.error!)
          : lessonProvider.userLessons.isEmpty
          ? const Center(child: Text("No categories to display"))
          : _buildTopicAndLessonList(
          lessonProvider, livesProvider, userStatProvider),
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

  Widget _buildTopicAndLessonList(
      LessonProvider lessonProvider, LivesProvider livesProvider, UserStatProvider userStatProvider) {
    if (lessonProvider.topics.isEmpty) {
      return const Center(child: Text("No topics available."));
    }

    return ListView.builder(
      itemCount: lessonProvider.topics.length,
      itemBuilder: (context, index) {
        final Topic topic = lessonProvider.topics[index];

        return _buildTopicItem(
            context, lessonProvider, topic, livesProvider, userStatProvider);
      },
    );
  }

  Widget _buildTopicItem(BuildContext context, LessonProvider lessonProvider,
      Topic topic, LivesProvider livesProvider, UserStatProvider userStatProvider) {
    return GestureDetector(
      onTap: () async {
        lessonProvider.toggleTopic(topic.documentId);
        if (topic.isExpanded) {
          await lessonProvider.selectTopic(topic.documentId);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopicHeader(topic),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: topic.isExpanded
                  ? lessonProvider.isLoadingLessons
                  ? _buildLessonLoadingIndicator()
                  : _buildLessonList(
                  context, lessonProvider, topic, livesProvider, userStatProvider)
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonLoadingIndicator() {
    return Container(
      height: 100,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  Widget _buildTopicHeader(Topic topic) {
    final topicColors = _topicColors[topic.name] ?? _topicColors["default"]!; // Default if not found
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 80,
          width: constraints.maxWidth,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: topicColors.headerColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(topic.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              _buildAnimatedArrow(topic),
            ],
          ),
        );
      },
    );
  }


  Widget _buildAnimatedArrow(Topic topic) {
    return AnimatedRotation(
      duration: const Duration(milliseconds: 300),
      turns: topic.isExpanded ? 0.5 : 0,
      child: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
    );
  }

  Widget _buildLessonList(BuildContext context, LessonProvider lessonProvider,
      Topic topic, LivesProvider livesProvider, UserStatProvider userStatProvider) {
    List<Lesson> lessons = lessonProvider.lessons
        .where((lesson) => lesson.topicId == topic.documentId)
        .toList();
    




    if (lessons.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text("No lessons available for this topic."),
      );
    }

    List<List<Lesson>> groupedLessons = _groupLessonsIntoRows(lessons, 3);

    List<Widget> rowWidgets = [];

    for (var lessonRow in groupedLessons) {
      rowWidgets.add(
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: lessonRow.asMap().entries.map((entry) {
              int index = entry.key;
              Lesson lesson = entry.value;
              return _buildLessonItem(
                  context, lesson, livesProvider, lessonRow.length, index, topic);
            }).toList()),
      );
      rowWidgets.add(const SizedBox(height: 32));
    }

    return Column(
      children: rowWidgets,
    );
  }


  List<List<Lesson>> _groupLessonsIntoRows(List<Lesson> lessons, int rowSize) {
    List<List<Lesson>> groupedLessons = [];
    for (int i = 0; i < lessons.length; i += rowSize) {
      int end = (i + rowSize < lessons.length) ? i + rowSize : lessons.length;
      groupedLessons.add(lessons.sublist(i, end));
    }
    return groupedLessons;
  }

  final Map<String, _TopicColors> _topicColors = {

    "Writing Code" : _TopicColors(
      headerColor: Colors.lightBlue,
      lessonColor: Colors.lightBlue,
    ),
    "Memory & Variable" : _TopicColors(
      headerColor: Colors.redAccent,
      lessonColor: Colors.redAccent,
    ),
    "Numerical Data" : _TopicColors(
      headerColor: Colors.amber,
      lessonColor: Colors.amber,
    ),

    "default" : _TopicColors(
      headerColor: Colors.greenAccent,
      lessonColor: Colors.greenAccent,
    )
  };



  Widget _buildLessonItem(BuildContext context, Lesson lesson, LivesProvider livesProvider, int rowLength, int index, Topic topic) {
    final topicColors = _topicColors[topic.name] ?? _topicColors["default"]!;
    final userState = Provider.of<UserStatProvider>(context);
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            _buildDirectionalArrow(rowLength, index),
            if (userState.questionIds.contains(lesson.documentId))
              _circleIcon(
                Icons.play_circle_fill,
                Colors.grey,
                onTap: () async {
                  if (livesProvider.lives?.currentLives == 0) {
                    _showNoLivesDialog(context);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserLessonContent(documentId: lesson.documentId),
                      ),
                    );
                  }
                },
              )
            else
              _circleIcon(
                Icons.play_circle_fill,
                topicColors.lessonColor,
                onTap: () async {
                  if (livesProvider.lives?.currentLives == 0) {
                    _showNoLivesDialog(context);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserLessonContent(documentId: lesson.documentId),
                      ),
                    );
                  }
                },
              ),
          ],
        ),
        Text(
          lesson.questionName,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildDirectionalArrow(int rowLength, int index) {
    if (index == rowLength - 1) {
      return const SizedBox();
    }

    return Positioned(
        right: -20,
        child: Icon(
            Icons.arrow_forward_rounded,
            color: Colors.grey[400],
            size: 28
        )
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

  void _showNoLivesDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Lives Left'),
          content:
          const Text('You have run out of lives. Please wait for them to refill.'),
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

class _TopicColors {
  final Color headerColor;
  final Color lessonColor;

  _TopicColors({required this.headerColor, required this.lessonColor});
}

