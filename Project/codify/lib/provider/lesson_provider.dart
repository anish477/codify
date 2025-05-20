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
  static bool _staticInitialized = false;
  static bool _dataBeingFetched = false;
  static List<UserLesson> _cachedUserLessons = [];
  static List<Topic> _cachedTopics = [];
  static List<Lesson> _cachedLessons = [];

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
  bool _isInitialized = false;
  bool _dataFetchInProgress = false;
  DateTime _lastFetchTime = DateTime.now().subtract(const Duration(days: 1));

  // Getters
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

  final bool _allTopicsExpanded = true;
  bool get allTopicsExpanded => _allTopicsExpanded;

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
    if (_cachedUserLessons.isNotEmpty) {
      _userLessons = _cachedUserLessons;
      _topics = _cachedTopics;
      _lessons = _cachedLessons;
      isLoading = false;
      _isInitialized = true;
      _staticInitialized = true;
      print("LessonProvider: Using cached data");
    } else if (!_staticInitialized && !_dataBeingFetched) {
      print("LessonProvider: Initial load");
      loadData();
    } else {
      print(
          "LessonProvider: Skip loading - static initialized: $_staticInitialized, fetching: $_dataBeingFetched");
    }
  }

  Future<void> _refreshDataAfterHotReload() async {
    print("LessonProvider: Quiet refresh after hot reload");
    try {
      _dataBeingFetched = true;
      _userId = await _auth.getUID();
      if (_userId != null) {
        await _loadPersistedCategory();
        await _loadSelectedTopic();
        await _fetchUserLessons();
        if (_selectedCategoryId != null) {
          await _fetchTopicsAndAllLessonsForCategory(_selectedCategoryId!);
          await _setupTopicsExpandState();
        }
      }
      _dataBeingFetched = false;
    } catch (e) {
      _dataBeingFetched = false;
      print("Error refreshing after hot reload: $e");
    }
  }

  Future<void> loadData() async {
    final now = DateTime.now();
    if (_dataFetchInProgress ||
        _dataBeingFetched ||
        now.difference(_lastFetchTime).inSeconds < 2 ||
        (_isInitialized && _cachedUserLessons.isNotEmpty)) {
      print(
          "LessonProvider: Data fetch skipped - already fetching or too recent or using cache");
      return;
    }

    _dataFetchInProgress = true;
    _dataBeingFetched = true;
    _lastFetchTime = now;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    print("LessonProvider: Starting data loading process");

    try {
      await _initializeUserId();
      if (_userId == null) {
        _showError("User ID not available.");
        return;
      }

      await _loadPersistedCategory();
      await _loadSelectedTopic();

      await _fetchUserLessons();

      if (_userLessons.isNotEmpty && _selectedCategoryId == null) {
        _selectedCategoryId = _userLessons.first.documentId;
        _userCategoryName = _userLessons.first.userCategoryName;
        await _savePersistedCategory(_selectedCategoryId!);
      }

      if (_selectedCategoryId != null) {
        await _fetchTopicsAndAllLessonsForCategory(_selectedCategoryId!);

        final userLesson = _userLessons.firstWhereOrNull(
            (lesson) => lesson.documentId == _selectedCategoryId);
        if (userLesson != null) {
          _selectedCategoryName = userLesson.userCategoryName;
        }
      }

      await _setupTopicsExpandState();

      _cachedUserLessons = List.from(_userLessons);
      _cachedTopics = List.from(_topics);
      _cachedLessons = List.from(_lessons);

      _isInitialized = true;
      _staticInitialized = true;
      print("LessonProvider: Data loading completed successfully");
    } catch (e) {
      print("LessonProvider ERROR: ${e.toString()}");
      _showError(
          "An unexpected error occurred during loading: ${e.toString()}");
    } finally {
      isLoading = false;
      _dataFetchInProgress = false;
      _dataBeingFetched = false;
      notifyListeners();
    }
  }

  Future<void> _setupTopicsExpandState() async {
    try {
      if (_selectedTopicId != null) {
        final topicToExpand =
            _topics.firstWhereOrNull((t) => t.documentId == _selectedTopicId);

        if (topicToExpand != null) {
          topicToExpand.isExpanded = true;
        } else {
          _selectedTopicId = null;
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(_selectedTopicKey);
        }
      }
    } catch (e) {
      print("Error setting up topic expand state: ${e.toString()}");
    }
  }

  Future<void> refresh() async {
    final now = DateTime.now();
    if (_dataFetchInProgress || now.difference(_lastFetchTime).inSeconds < 2) {
      print("LessonProvider: Refresh skipped - already fetching or too recent");
      return;
    }

    _lastFetchTime = now;
    _dataFetchInProgress = true;
    errorMessage = null;

    try {
      if (_userId == null) {
        await _initializeUserId();
      }

      if (_userId != null) {
        await _fetchUserLessons();

        if (_selectedCategoryId != null) {
          isLoading = true;
          notifyListeners();
          await _fetchTopicsAndAllLessonsForCategory(_selectedCategoryId!);
          isLoading = false;
        }

        await _setupTopicsExpandState();

        // Update cached data
        _cachedUserLessons = List.from(_userLessons);
        _cachedTopics = List.from(_topics);
        _cachedLessons = List.from(_lessons);
      }

      _isInitialized = true;
      _staticInitialized = true;
    } catch (e) {
      print("LessonProvider refresh ERROR: ${e.toString()}");
      _showError("Error during refresh: ${e.toString()}");
    } finally {
      _dataFetchInProgress = false;
      notifyListeners();
    }
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

  Future<void> selectCategory(String? categoryName, String? categoryId) async {
    print(
        "LessonProvider: selectCategory called with name=$categoryName, id=$categoryId");

    bool originalPanelState = isPanelOpen;

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

      try {
        await _fetchTopicsAndAllLessonsForCategory(categoryId);

        final userLesson = _userLessons
            .firstWhereOrNull((lesson) => lesson.documentId == categoryId);
        if (userLesson != null) {
          _selectedCategoryName = userLesson.userCategoryName;
          _userCategoryName = userLesson.userCategoryName;
        }

        _cachedUserLessons = List.from(_userLessons);
        _cachedTopics = List.from(_topics);
        _cachedLessons = List.from(_lessons);

        _isInitialized = true;
        _staticInitialized = true;

        print(
            "LessonProvider: Category selection completed. Topics: ${_topics.length}, Lessons: ${_lessons.length}");
      } catch (e) {
        print(
            "LessonProvider ERROR: Error selecting category: ${e.toString()}");
      } finally {
        isLoading = false;

        if (originalPanelState) {
          isPanelOpen = false;
        }

        notifyListeners();
      }
    } else {
      _topics = [];
      _lessons = [];
      notifyListeners();
    }
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
        topic.isExpanded = true;
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
    }
  }

  void toggleTopic(String topicId) {
    bool needsNotify = false;
    Topic? toggledTopic;

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
    _isInitialized = false;
    _dataFetchInProgress = false;

    _cachedUserLessons = [];
    _cachedTopics = [];
    _cachedLessons = [];
    _staticInitialized = false;

    notifyListeners();
  }

  Future<void> initializeForNavigation(List<UserLesson> userLessons) async {
    print(
        "LessonProvider: Initializing for navigation with ${userLessons.length} lessons");

    try {
      await _initializeUserId();
      if (_userId == null) {
        print("LessonProvider: Error initializing - No user ID available");
        return;
      }

      if (userLessons.isNotEmpty) {
        _userLessons = List.from(userLessons);
        _cachedUserLessons = List.from(userLessons);

        if (_selectedCategoryId == null) {
          final firstLesson = userLessons.first;
          await selectCategory(
              firstLesson.userCategoryName, firstLesson.documentId);
          print(
              "LessonProvider: First category selected: ${firstLesson.userCategoryName}");
        } else {
          print(
              "LessonProvider: Using existing category selection: $_selectedCategoryId");

          await _fetchTopicsAndAllLessonsForCategory(_selectedCategoryId!);
        }

        _isInitialized = true;
        _staticInitialized = true;
      } else {
        print("LessonProvider: No lessons provided for initialization");
      }
    } catch (e) {
      print("LessonProvider: Error during navigation initialization: $e");
    } finally {
      isLoading = false;
      _dataFetchInProgress = false;
      _dataBeingFetched = false;
      notifyListeners();
    }
  }

  Future<void> prepareForNavigation(String? categoryName, String? categoryId,
      List<UserLesson> userLessons) async {
    print(
        "LessonProvider: Preparing for navigation with categoryId=$categoryId, name=$categoryName");

    try {
      _topics = [];
      _lessons = [];
      isLoading = true;

      await _initializeUserId();
      if (_userId == null) {
        print(
            "LessonProvider ERROR: Failed to get user ID during navigation preparation");
        return;
      }

      _userLessons = List.from(userLessons);
      _cachedUserLessons = List.from(userLessons);

      _selectedCategoryId = categoryId;
      _selectedCategoryName = categoryName;
      _userCategoryName = categoryName;

      if (categoryId != null) {
        await _savePersistedCategory(categoryId);
      }

      if (categoryId != null) {
        await _fetchTopicsAndAllLessonsForCategory(categoryId);

        await _setupTopicsExpandState();

        _cachedTopics = List.from(_topics);
        _cachedLessons = List.from(_lessons);
      }

      _isInitialized = true;
      _staticInitialized = true;

      print(
          "LessonProvider: Navigation preparation complete. Topics: ${_topics.length}, Lessons: ${_lessons.length}");
    } catch (e) {
      print(
          "LessonProvider ERROR: Error during navigation preparation: ${e.toString()}");
    } finally {
      isLoading = false;
      _dataFetchInProgress = false;
      _dataBeingFetched = false;
      notifyListeners();
    }
  }
}
