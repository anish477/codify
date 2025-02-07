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
import 'user_lesson_content.dart';

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
  String? _userId;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeUserId();
  }

  Future<void> _initializeUserId() async {
    _userId = await _auth.getUID();
    if (_userId != null) {
      _fetchInitialData();
    } else {
      _showError("Failed to get user ID.");
    }
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
      if (_topics.isNotEmpty) {
        await _fetchLessons(_topics[0].documentId);
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchUserLessons() async {
    try {
      if (_userId == null) return;

      final userLessons = await _userLessonService.getUserLessonByUserId(_userId!);
      if (mounted) {
        setState(() {
          _userLessons = userLessons;
          _selectedCategoryName = _userLessons.isNotEmpty ? _userLessons[0].userCategoryName : null;
        });
      }
    } catch (e) {
      _showError("Failed to load user lessons.");
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
      _showError("Failed to load topics.");
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
      _showError("Failed to load lessons.");
    }
  }

  void _showError(String message) {
    if (mounted) {
      setState(() {
        errorMessage = message;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double panelHeight = _userLessons.length * 56.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Lesson Main",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? _buildLoadingUI()
          : errorMessage != null
          ? _buildErrorUI()
          : _userLessons.isEmpty
          ? const Center(child: Text("No categories to display"))
          : _buildLessonContent(panelHeight),
    );
  }

  Widget _buildLoadingUI() {
    return Center(
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
                      const Icon(Icons.arrow_downward, color: Colors.white),
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
    );
  }

  Widget _buildErrorUI() {
    return Center(
      child: Text(
        errorMessage!,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildLessonContent(double panelHeight) {
    return Column(
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
                  style: const TextStyle(color: Colors.white),
                ),
                Icon(isPanelOpen ? Icons.arrow_upward : Icons.arrow_downward),
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
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => UserLessonContent(documentId: lesson.documentId)));
                  },
                )).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}