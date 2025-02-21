import 'package:flutter/material.dart';
import 'package:codify/lesson/category_service.dart';
import 'package:codify/lesson/topic_service.dart';
import 'package:codify/lesson/topic.dart';
import 'package:codify/lesson/lesson_service.dart';
import 'package:codify/lesson/lesson.dart';
import '../user/user_lesson_service.dart';
import '../services/auth.dart';
import '../user/user_lesson.dart';

class LessonProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  final UserLessonService _userLessonService = UserLessonService();
  final AuthService _auth = AuthService();
  final TopicService _topicService = TopicService();
  final LessonService _lessonService = LessonService();

  List<UserLesson> _userLessons = [];
  List<Topic> _topics = [];
  List<Lesson> _lessons = [];
  final List<String> _selectedCategories = [];
  bool isLoading = true;
  bool isPanelOpen = false;
  String? _selectedCategoryName;
  String? _userId;
  String? errorMessage;
  String? _selectedTopicId;
  String? _selectedCategoryId;

  List<UserLesson> get userLessons => _userLessons;
  List<Topic> get topics => _topics;
  List<Lesson> get lessons => _lessons;
  List<String> get selectedCategories => _selectedCategories;
  bool get loading => isLoading;
  bool get panelOpen => isPanelOpen;
  String? get selectedCategoryName => _selectedCategoryName;
  String? get userId => _userId;
  String? get error => errorMessage;
  String? get selectedTopicId => _selectedTopicId;
  String? get selectedCategoryId => _selectedCategoryId;

  LessonProvider() {
    _initializeUserId();
  }

  Future<void> _initializeUserId() async {
    _userId = await _auth.getUID();
    if (_userId != null) {
      await _fetchInitialData();
    } else {
      _showError("Failed to get user ID.");
    }
  }

  Future<void> _fetchInitialData() async {
    isLoading = true;
    notifyListeners();

    await Future.wait([
      _fetchUserLessons(),
    ]);

    if (_userLessons.isNotEmpty && _userLessons[0].userCategoryName != null) {
      _selectedCategoryId = _userLessons[0].userId;
      await _fetchTopics(_userLessons[0].userCategoryName!);
      if (_topics.isNotEmpty) {
        selectTopic(_topics[0].documentId);
      }
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchUserLessons() async {
    try {
      if (_userId == null) return;

      final userLessons = await _userLessonService.getUserLessonByUserId(_userId!);
      _userLessons = userLessons;
      _selectedCategoryName = _userLessons.isNotEmpty ? _userLessons[0].userCategoryName : null;
      notifyListeners();
    } catch (e) {
      _showError("Failed to load user lessons.");
    }
  }

  Future<void> _fetchTopics(String userCategoryId) async {
    try {
      final topics = await _topicService.getAllTopics();
      _topics = topics.where((topic) => topic.categoryId == userCategoryId).toList();
      if (_topics.isNotEmpty) {
        _selectedTopicId = _topics[0].documentId;
        await _fetchLessons(_topics[0].documentId);
      }
      notifyListeners();
    } catch (e) {
      _showError("Failed to load topics.");
    }
  }

  Future<void> _fetchLessons(String topicId) async {
    try {
      final lessons = await _lessonService.getLessonsByTopicId(topicId);
      _lessons = lessons;
      notifyListeners();
    } catch (e) {
      _showError("Failed to load lessons.");
    }
  }

  void _showError(String message) {
    errorMessage = message;
    notifyListeners();
  }

  void togglePanel() {
    isPanelOpen = !isPanelOpen;
    notifyListeners();
  }

  void selectCategory(String? categoryName, String? categoryId) {
    _selectedCategoryName = categoryName;
    _selectedCategoryId = categoryId;
    if (categoryId != null) {
      _fetchTopics(categoryId);
    }
    togglePanel();
  }

  void selectTopic(String topicId) {
    _selectedTopicId = topicId;
    _fetchLessons(topicId);
  }

  void toggleCategory(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    notifyListeners();
  }
}