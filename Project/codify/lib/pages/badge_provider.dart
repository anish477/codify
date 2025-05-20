import 'package:codify/gamification/badge.dart';
import 'package:codify/gamification/badge_service.dart';
import 'package:flutter/foundation.dart';

class BadgeProvider extends ChangeNotifier {
  final BadgeService _badgeService = BadgeService();
  List<Badge> _userBadges = [];
  bool _isLoading = false;
  String? _error;

  List<Badge> get badges => _userBadges;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserBadges(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userBadges = await _badgeService.getBadgesForUser(userId);
    } catch (e) {
      _error = 'Failed to load badges: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> awardFirstLessonBadge(String userId, String topicId) async {
    try {
      final result = await _badgeService.awardFirstLessonBadge(userId, topicId);
      if (result) {
        await loadUserBadges(userId);
      }
      return result;
    } catch (e) {
      _error = 'Failed to award badge: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> awardTopicMasteryBadge(String userId, String topicId) async {
    try {
      final result =
          await _badgeService.awardTopicMasteryBadge(userId, topicId);
      if (result) {
        await loadUserBadges(userId);
      }
      return result;
    } catch (e) {
      _error = 'Failed to award badge: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
