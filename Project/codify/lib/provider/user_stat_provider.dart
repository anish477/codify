import 'package:flutter/material.dart';
import '../user/user_stat_service.dart';
import '../services/auth.dart';

class UserStatProvider with ChangeNotifier {
  final UserStatService _userStatService = UserStatService();
  final AuthService _auth = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  List<String> _questionIds = [];
  String? _userId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get questionIds => _questionIds;

  UserStatProvider() {
    getUserStats();
    notifyListeners();
  }

  Future<void> markQuestionAsComplete(String userId, String topicId, String questionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userStatService.markQuestionAsComplete(userId, topicId, questionId);
    } catch (e) {
      _errorMessage = 'Error marking question as complete: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getUserStats() async {
    _userId = await _auth.getUID();
    notifyListeners();
    if (_userId != null) {
      _questionIds = await _userStatService.getUserStats(_userId!);
      notifyListeners();
    }
  }
}