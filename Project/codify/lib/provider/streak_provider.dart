import 'package:codify/gamification/streak.dart';
import 'package:codify/gamification/streak_service.dart';
import 'package:codify/services/auth.dart';
import 'package:flutter/material.dart';

class StreakProvider extends ChangeNotifier {
  final StreakService _streakService = StreakService();
  final AuthService _authService = AuthService();
  Streak? _streak;
  String? _userId;

  Streak? get streak => _streak;

  StreakProvider() {
    _initializeUserId();
  }

  Future<void> _initializeUserId() async {
    _userId = await _authService.getUID();
    if (_userId != null) {
      await getStreak();
    } else {
      _showError("Failed to get user ID.");
    }
  }

  Future<void> getStreak() async {
    if (_userId != null) {
      _streak = await _streakService.getStreakForUser(_userId!);
      notifyListeners();
    }
  }

  List<String> getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _streak?.dates.any((date) {
      final streakDate = DateTime(date.year, date.month, date.day);
      return streakDate.isAtSameMomentAs(normalizedDay);
    }) ?? false ? ['Streak'] : [];
  }

  Future<void> updateStreak() async {
    if (_userId != null) {
      await _streakService.updateStreak(_userId!);
      await getStreak();
    }
  }

  void _showError(String message) {

  }
}