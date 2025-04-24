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
import 'package:collection/collection.dart';

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
  static const String _selectedTopicKey = 'selectedTopicId';
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
    loadData();
  }

  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _initializeUserId();
      if (_userId == null) {
        _showError("User ID not available.");
        return;
      }

      await _loadPersistedCategory();
      await _loadSelectedTopic();

      await _fetchUserLessons();

      await _selectInitialCategoryAndExpandTopic(); //
    } catch (e, stackTrace) {
      _showError(
          "An unexpected error occurred during loading: ${e.toString()}");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadData();
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

  Future<void> _loadPersistedCategory() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedCategoryId = prefs.getString(_selectedCategoryKey);
  }

  Future<void> _selectInitialCategoryAndExpandTopic() async {
    try {
      String? initialCategoryId = _selectedCategoryId;
      String? initialCategoryName;

      if (initialCategoryId != null) {
        final userLessonForCategory = _userLessons.firstWhereOrNull(
            (lesson) => lesson.userCategoryId == initialCategoryId);
        if (userLessonForCategory != null) {
          initialCategoryName = userLessonForCategory.userCategoryName;
        } else {
          initialCategoryId = null;
          _selectedCategoryId = null;
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(_selectedCategoryKey);
        }
      }

      if (initialCategoryId == null && _userLessons.isNotEmpty) {
        initialCategoryId = _userLessons[0].userCategoryId;
        initialCategoryName = _userLessons[0].userCategoryName;
        _selectedCategoryId = initialCategoryId;

        if (initialCategoryId != null) {
          await _savePersistedCategory(initialCategoryId);
        }
      }

      if (initialCategoryId != null) {
        _selectedCategoryName = initialCategoryName;

        await _fetchTopicsAndAllLessonsForCategory(initialCategoryId);

        if (_selectedTopicId != null) {
          final initiallySelectedTopic =
              _topics.firstWhereOrNull((t) => t.documentId == _selectedTopicId);

          if (initiallySelectedTopic != null &&
              initiallySelectedTopic.categoryId == initialCategoryId) {
            initiallySelectedTopic.isExpanded = true;

            notifyListeners();
          } else {
            if (initiallySelectedTopic == null) {
            } else {}
            _selectedTopicId = null;
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove(_selectedTopicKey);
          }
        } else {}
      } else {
        _topics = [];
        _lessons = [];
      }
    } catch (e) {
      _showError("Failed to select initial category: ${e.toString()}");
      _topics = [];
      _lessons = [];
    } finally {}
  }

  Future<void> _fetchUserLessons() async {
    try {
      if (_userId == null) {
        return;
      }
      final userLessons =
          await _userLessonService.getUserLessonByUserId(_userId!);
      _userLessons = userLessons;
    } catch (e) {
      _showError("Failed to load user lessons: ${e.toString()}");
    }
  }

  Future<void> _loadSelectedTopic() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedTopicId = prefs.getString(_selectedTopicKey);
  }

  Future<void> _saveSelectedTopic(String topicId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedTopicKey, topicId);
  }

  void _showError(String message) {
    errorMessage = message;
    isLoading = false;

    notifyListeners();
  }

  void togglePanel() {
    isPanelOpen = !isPanelOpen;
    notifyListeners();
  }

  void selectCategory(String? categoryName, String? categoryId) async {
    if (_selectedCategoryId == categoryId) {
      togglePanel();
      return;
    }

    _selectedCategoryName = categoryName;
    _selectedCategoryId = categoryId;
    _selectedTopicId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedTopicKey);

    if (categoryId != null) {
      isLoading = true;
      notifyListeners();
      await _savePersistedCategory(categoryId);

      await _fetchTopicsAndAllLessonsForCategory(categoryId);
      isLoading = false;
    } else {
      _topics = [];
      _lessons = [];
      notifyListeners();
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

  Future<void> _savePersistedCategory(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedCategoryKey, categoryId);
  }

  Future<void> _fetchTopicsAndAllLessonsForCategory(String categoryId) async {
    try {
      final topics = await _topicService.getAllTopics();

      for (var topic in topics) {
        topic.isExpanded = false;
      }

      _topics =
          topics.where((topic) => topic.categoryId == categoryId).toList();

      if (_topics.isNotEmpty) {
        List<Future<List<Lesson>>> lessonFutures = _topics
            .map(
                (topic) => _lessonService.getLessonsByTopicId(topic.documentId))
            .toList();

        List<List<Lesson>> results = await Future.wait(lessonFutures);

        _lessons = results.expand((list) => list).toList();
      } else {
        _lessons = [];
      }
    } catch (e) {
      _showError(
          "Failed to load topics and lessons for category $categoryId: ${e.toString()}");
      _topics = [];
      _lessons = [];
    } finally {}

    notifyListeners();
  }

  void toggleTopic(String topicId) {
    Topic? toggledTopic;
    bool needsNotify = false;

    for (var topic in _topics) {
      if (topic.documentId == topicId) {
        if (!topic.isExpanded) {
          topic.isExpanded = true;
          toggledTopic = topic;
          needsNotify = true;
        } else {
          topic.isExpanded = false;
          needsNotify = true;

          if (_selectedTopicId == topicId) {
            _selectedTopicId = null;
            SharedPreferences.getInstance()
                .then((prefs) => prefs.remove(_selectedTopicKey));
          }
        }
      } else {
        if (topic.isExpanded) {
          topic.isExpanded = false;
          needsNotify = true;
        }
      }
    }

    if (toggledTopic != null && toggledTopic.isExpanded) {
      _selectedTopicId = topicId;
      _saveSelectedTopic(topicId);
    }

    if (needsNotify) {
      notifyListeners();
    }
  }

  void reset() {
    _userLessons = [];
    _topics = [];
    _lessons = [];
    _selectedCategories.clear();

    isLoading = true;
    isPanelOpen = false;

    _selectedCategoryName = null;
    _userId = null;
    errorMessage = null;
    _selectedTopicId = null;
    _selectedCategoryId = null;
    _userCategoryName = null;
    _questionId = null;

    notifyListeners();
  }
}
