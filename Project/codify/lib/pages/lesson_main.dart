import 'package:flutter/material.dart';
import 'package:codify/lesson/category_service.dart';
import 'package:codify/lesson/category.dart';
import 'package:codify/lesson/topic_service.dart';
import 'package:codify/lesson/topic.dart';
import 'package:codify/lesson/lesson_service.dart';
import 'package:codify/lesson/lesson.dart';
import '../user/user_lesson_service.dart';
import '../services/auth.dart';
import '../user/user_lesson.dart';
import 'package:shimmer/shimmer.dart';

class LessonMain extends StatefulWidget {
  const LessonMain({super.key});

  @override
  State<LessonMain> createState() => _LessonMainState();
}

class _LessonMainState extends State<LessonMain> {
  final CategoryService _categoryService = CategoryService();
  final UserLessonService _userLessonService = UserLessonService();
  final AuthService _auth = AuthService();
  final TopicService _topicService = TopicService();
  final LessonService _lessonService = LessonService();

  List<UserLesson> _userLessons = [];
  List<Topic> _topics = [];
  List<Lesson> _lessons = [];
  bool isLoading = true;
  bool isPanelOpen = false;
  String? _selectedCategoryName;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      isLoading = true;
    });
    await Future.wait([
      _fetchUserLessons(),
    ]);
    if (_userLessons.isNotEmpty && _userLessons[0].userCategoryName != null) {
      await _fetchTopics(_userLessons[0].userCategoryName!);
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchUserLessons() async {
    try {
      final String? userId = await _auth.getUID();
      if (userId == null) {
        setState(() {
          errorMessage = "User not logged in";
          _userLessons = [];
        });
        return;
      }

      final userLessons = await _userLessonService.getUserLessonByUserId(userId);
      if (mounted) {
        setState(() {
          _userLessons = userLessons;
          _selectedCategoryName = _userLessons.isNotEmpty ? _userLessons[0].userCategoryName : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Failed to load user lessons.";
          _userLessons = [];
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage ?? "Error fetching user lessons.")));
      }
    }
  }

  Future<void> _fetchTopics(String userCategoryId) async {
    try {
      final topics = await _topicService.getAllTopics();
      if (mounted) {
        setState(() {
          _topics = topics.where((topic) => topic.categoryId == userCategoryId).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Failed to load topics.";
          _topics = [];
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage ?? "Error fetching topics.")));
      }
    }
  }

  Future<void> _fetchLessons(String topicId) async {
    try {
      final lessons = await _lessonService.getLessonsByTopicId(topicId);
      if (mounted) {
        setState(() {
          _lessons = lessons;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Failed to load lessons.";
          _lessons = [];
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage ?? "Error fetching lessons.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double panelHeight = _userLessons.length * 56.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lesson Main"),
      ),
      body: isLoading
          ? Center(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: [
              Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.blue,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 100,
                          height: 20,
                          color: Colors.grey[300],
                        ),
                        const Icon(Icons.arrow_downward,
                            color: Colors.white),
                      ])),
              Expanded(
                  child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Container(
                            height: 16,
                            width: 100,
                            color: Colors.grey[300],
                          ),
                          subtitle: Container(
                            height: 10,
                            width: 80,
                            color: Colors.grey[300],
                          ),
                        );
                      }))
            ],
          ),
        ),
      )
          : errorMessage != null
          ? Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      )
          : _userLessons.isEmpty
          ? const Center(
        child: Text("No categories to display"),
      )
          : Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              setState(() {
                isPanelOpen = !isPanelOpen;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.blue,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCategoryName ?? 'Select Category',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  Icon(isPanelOpen
                      ? Icons.arrow_upward
                      : Icons.arrow_downward),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isPanelOpen ? panelHeight : 0.0,
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _userLessons.length,
              itemBuilder: (context, index) {
                final category = _userLessons[index];
                return Container(
                  color: Colors.grey[200],
                  child: ListTile(
                    title: Text(category.userCategoryName ?? "No"),
                    onTap: () {
                      setState(() {
                        _selectedCategoryName = category.userCategoryName;
                        isPanelOpen = false;
                        if (category.userCategoryId != null) {
                          _fetchTopics(category.userCategoryId!);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _topics.length,
              itemBuilder: (context, index) {
                final topic = _topics[index];
                return ExpansionTile(
                  title: Text(topic.name),
                  onExpansionChanged: (isExpanded) {
                    if (isExpanded) {
                      _fetchLessons(topic.documentId);
                    }
                  },
                  children: _lessons.map((lesson) => ListTile(
                    title: Text(lesson.questionName),
                  )).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}