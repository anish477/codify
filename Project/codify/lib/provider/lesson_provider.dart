import 'package:flutter/material.dart';
import 'package:codify/lesson/category_service.dart';
import 'package:codify/lesson/topic_service.dart';
import 'package:codify/lesson/topic.dart';
import 'package:codify/lesson/lesson_service.dart';
import 'package:codify/lesson/lesson.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../user/user_lesson_service.dart';
import '../services/auth.dart';
import '../user/user_lesson.dart';

class LessonProvider extends ChangeNotifier {
  final CategoryService _categoryService;
  final UserLessonService _userLessonService;
  final AuthService _auth;
  final TopicService _topicService;
  final LessonService _lessonService;

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
  String? _userCategoryName;
  String? _questionId;

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
  String? get userCategoryName => _userCategoryName;
  String? get selectedCategoryId => _selectedCategoryId;
  static const String _selectedLessonKey = 'selectedLessonId';
  static const String _selectedCategoryKey = 'selectedCategoryId';

  LessonProvider({
    CategoryService? categoryService,
    UserLessonService? userLessonService,
    AuthService? auth,
    TopicService? topicService,
    LessonService? lessonService,
  })  : _categoryService = categoryService ?? CategoryService(),
        _userLessonService = userLessonService ?? UserLessonService(),
        _auth = auth ?? AuthService(),
        _topicService = topicService ?? TopicService(),
        _lessonService = lessonService ?? LessonService() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _initializeUserId();
    await _fetchAllTopicsAndLessons();


    await _loadPersistedCategory();


    await _selectInitialCategory();
  }

  Future<void> _initializeUserId() async {
    try {
      _userId = await _auth.getUID();
      if (_userId == null) {
        _showError("Failed to get user ID.");
      }
    } catch (e) {
      _showError("Failed to get user ID: ${e.toString()}");
    }
  }

  // Method to load the category ID from SharedPreferences
  Future<void> _loadPersistedCategory() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedCategoryId = prefs.getString(_selectedCategoryKey);
  }

  // Method to automatically select initial category
  Future<void> _selectInitialCategory() async {
    isLoading = true;
    notifyListeners();

    try {
      await _fetchUserLessons();


      if (_selectedCategoryId != null) {

        try {
          String initialCategoryName = _userLessons
              .firstWhere((lesson) => lesson.userCategoryId == _selectedCategoryId)
              .userCategoryName!;

          _selectedCategoryName = initialCategoryName;
          await _fetchTopics(_selectedCategoryId!);

          print('Loaded persisted category: $_selectedCategoryName with ID: $_selectedCategoryId');

        } catch (e) {
          _showError("Failed to find a category with the persisted ID: $_selectedCategoryId.");
        }

      } else if (_userLessons.isNotEmpty && _userLessons[0].userCategoryName != null) {
        String initialCategoryName = _userLessons[0].userCategoryName!;
        String initialCategoryId = _userLessons[0].userCategoryId!;

        _selectedCategoryName = initialCategoryName;
        _selectedCategoryId = initialCategoryId;


        await _fetchTopics(initialCategoryId);
      } else {
        _showError("No categories available for the user.");
      }
    } catch (e) {
      _showError("Failed to select initial category: ${e.toString()}");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchUserLessons() async {
    try {
      if (_userId == null) return;

      final userLessons = await _userLessonService.getUserLessonByUserId(_userId!);
      _userLessons = userLessons;
      notifyListeners();
    } catch (e) {
      _showError("Failed to load user lessons: ${e.toString()}");
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
      _showError("Failed to load topics: ${e.toString()}");
    }
  }

  Future<void> _fetchLessons(String topicId) async {
    try {
      final lessons = await _lessonService.getLessonsByTopicId(topicId);
      _lessons = lessons;
      notifyListeners();
    } catch (e) {
      _showError("Failed to load lessons: ${e.toString()}");
    }
  }

  Future<void> _loadSelectedLesson() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedLessonId = prefs.getString(_selectedLessonKey);
    if (selectedLessonId != null) {
      _selectedTopicId = selectedLessonId;
      await _fetchLessons(selectedLessonId);
    }
  }

  void selectTopic(String topicId) async {
    _selectedTopicId = topicId;
    await _fetchLessons(topicId);
    _saveSelectedLesson(topicId);
  }

  Future<void> _saveSelectedLesson(String topicId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedLessonKey, topicId);
  }

  void _showError(String message) {
    errorMessage = message;
    print('Error: $message');
    notifyListeners();
  }

  void togglePanel() {
    isPanelOpen = !isPanelOpen;
    notifyListeners();
  }

  void selectCategory(String? categoryName, String? categoryId) async {
    _selectedCategoryName = categoryName;
    _selectedCategoryId = categoryId;

    if (categoryId != null) {
      await _savePersistedCategory(categoryId);
      await _fetchTopics(categoryId);
    }

    togglePanel();
  }

  void toggleCategory(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    notifyListeners();
  }

  Future<void> _fetchAllTopicsAndLessons() async {
    try {
      final topics = await _topicService.getAllTopics();
      _topics = topics;

      // Fetch Lessons for Topic
      for (var topic in topics) {
        await _fetchLessons(topic.documentId);
      }
      notifyListeners();
    } catch (e) {
      _showError("Failed to load topics and lessons: ${e.toString()}");
    }
  }


  Future<void> _savePersistedCategory(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedCategoryKey, categoryId);
  }
  void reset() {

    _lessons = [];
    notifyListeners();
  }
}