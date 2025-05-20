import 'package:codify/gamification/streak.dart';
import 'package:codify/gamification/streak_service.dart';
import 'package:codify/services/auth.dart';
import 'package:flutter/material.dart';

class StreakProvider extends ChangeNotifier {
  final StreakService _streakService = StreakService();
  final AuthService _authService = AuthService();
  Streak? _streak;
  String? _userId;
  bool _isLoading = true;

  Streak? get streak => _streak;
  bool get isLoading => _isLoading;

  StreakProvider() {
    _initializeUserId();
  }

  Future<void> _initializeUserId() async {
    _isLoading = true;
    notifyListeners();

    _userId = await _authService.getUID();
    if (_userId != null) {
      await getStreak();
    } else {
      _showError("Failed to get user ID.");
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getStreak() async {
    if (_userId != null) {
      _isLoading = true;
      notifyListeners();

      try {
        _streak = await _streakService.getStreakForUser(_userId!);
      } catch (e) {
        _showError("Failed to load streak data: $e");
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  List<String> getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _streak?.dates.any((date) {
              final streakDate = DateTime(date.year, date.month, date.day);
              return streakDate.isAtSameMomentAs(normalizedDay);
            }) ??
            false
        ? ['Streak']
        : [];
  }

  Future<void> updateStreak() async {
    if (_userId != null) {
      _isLoading = true;
      notifyListeners();

      try {
        await _streakService.updateStreak(_userId!);
        await getStreak();
      } catch (e) {
        _showError("Failed to update streak: $e");
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void reset() {
    _streak = null;
    _isLoading = true;
    notifyListeners();
  }

  void _showError(String message) {
    
    debugPrint("StreakProvider Error: $message");
  }
}
