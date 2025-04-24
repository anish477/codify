import 'package:flutter/material.dart';
import '../gamification/leaderboard_service.dart';
import '../services/auth.dart';

class LeaderboardProvider extends ChangeNotifier {
  final LeaderboardService _leaderboardService = LeaderboardService();
  final AuthService _authService = AuthService();

  Map<String, int> _userPoints = {};
  int _totalWeeklyPoints = 0;
  bool _wasPointsReset = false;
  String? _userId;

  Map<String, int> get userPoints => _userPoints;
  Map<String, int> get userPointsForGraph => _userPoints;
  int get totalWeeklyPoints => _totalWeeklyPoints;
  bool get wasPointsReset => _wasPointsReset;

  LeaderboardProvider() {
    _initializeLeaderboard();
  }

  Future<void> _initializeLeaderboard() async {
    _userId = await _authService.getUID();

    if (_userId != null) {
      await Future.wait([
        _fetchUserPoints(),
        getTotalPointsByUserPerDayLast7Days(),
      ]);
    }
  }

  Future<void> _fetchUserPoints() async {
    _userPoints = await _leaderboardService.getTotalPointsByUserLast7Days();
    notifyListeners();
  }

  Future<void> getTotalPointsByUserPerDayLast7Days() async {
    if (_userId != null) {
      final weeklyPointsData =
          await _leaderboardService.getWeeklyPointsWithReset(_userId!);
      _totalWeeklyPoints = weeklyPointsData['totalPoints'] ?? 0;
      _wasPointsReset = weeklyPointsData['wasReset'] ?? false;
      notifyListeners();
    }
  }

  Future<void> refreshLeaderboard() async {
    if (_userId != null) {
      await Future.wait([
        _fetchUserPoints(),
        getTotalPointsByUserPerDayLast7Days(),
      ]);
    } else {
      _initializeLeaderboard();
    }
  }
}
