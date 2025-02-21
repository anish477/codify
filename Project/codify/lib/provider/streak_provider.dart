import 'package:codify/gamification/streak.dart';
import 'package:codify/gamification/streak_service.dart';
import 'package:codify/services/auth.dart';
import 'package:flutter/material.dart';

class StreakProvider extends ChangeNotifier {
  final StreakService _streakService = StreakService();
  final AuthService _authService = AuthService();
  Streak? _streak;

  Streak? get streak => _streak;

  StreakProvider() {
    getStreak();
  }

  Future<void> getStreak() async {
    final user = await _authService.getUID();
    if (user != null) {
      _streak = await _streakService.getStreakForUser(user);
      notifyListeners();
    }
  }

  List<String> getEventsForDay(DateTime day) {
    return _streak?.dates.contains(day) ?? false ? ['Streak'] : [];
  }
}