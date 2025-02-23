import 'package:flutter/material.dart';
import '../gamification/leaderboard.dart';
import '../gamification/leaderboard_service.dart';
import '../services/auth.dart';

class LeaderboardProvider extends ChangeNotifier {
  final LeaderboardService _leaderboardService = LeaderboardService();
  final AuthService _authService = AuthService();

  List<Leaderboard> _leaderboardEntries = [];
  Map<String, int> _userPoints = {};

  List<Leaderboard> get leaderboardEntries => _leaderboardEntries;
  Map<String, int> get userPoints => _userPoints;

  LeaderboardProvider() {
    _initializeLeaderboard();
  }

  Future<void> _initializeLeaderboard() async {
    final user = await _authService.getUID();
    if (user != null) {
      await _fetchLeaderboardEntries(user);
      await _fetchUserPoints();
    }
  }

  Future<void> _fetchLeaderboardEntries(String userId) async {
    _leaderboardEntries = await _leaderboardService.getLeaderboardByUserId(userId);
    notifyListeners();
  }

  Future<void> _fetchUserPoints() async {
    _userPoints = await _leaderboardService.getTotalPointsByUserLast7Days();
    notifyListeners();
  }

  Future<void> addLeaderboardEntry(Leaderboard leaderboard) async {
    await _leaderboardService.addLeaderboardEntry(leaderboard);
    await _fetchLeaderboardEntries(leaderboard.userId);
  }

  Future<void> refreshLeaderboard() async {
    final user = await _authService.getUID();
    if (user != null) {
      await _fetchLeaderboardEntries(user);
      await _fetchUserPoints();
    }
  }
}