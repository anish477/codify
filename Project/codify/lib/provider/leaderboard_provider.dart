import 'package:flutter/material.dart';
import '../gamification/leaderboard.dart';
import '../gamification/leaderboard_service.dart';
import '../services/auth.dart';

class LeaderboardProvider extends ChangeNotifier {
  final LeaderboardService _leaderboardService = LeaderboardService();
  final AuthService _authService = AuthService();

  List<Leaderboard> _leaderboardEntries = [];
  Map<String, int> _userPoints = {};
  Map<String, int> _userPointsForGraph = {};
  String? _userId;

  List<Leaderboard> get leaderboardEntries => _leaderboardEntries;
  Map<String, int> get userPoints => _userPoints;
  Map<String, int> get userPointsForGraph => _userPointsForGraph;

  LeaderboardProvider() {
    _initializeLeaderboard();
  }

  Future<void> _initializeLeaderboard() async {
    _userId = await _authService.getUID();

    if (_userId != null) {
      await Future.wait([
        _fetchLeaderboardEntries(_userId!),
        _fetchUserPoints(),
        getTotalPointsByUserPerDayLast7Days(),
      ]);
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
    if (_userId != null) {
      await _fetchLeaderboardEntries(_userId!);
    } else {
      _userId = await _authService.getUID();
      if(_userId != null){
      }
    }

  }

  Future<void> getTotalPointsByUserPerDayLast7Days() async {
    if (_userId != null) {
      _userPointsForGraph = await _leaderboardService.getTotalPointsByUserPerDayLast7Days(_userId!);
      notifyListeners();
    }else{
      _userId = await _authService.getUID();
      if(_userId != null){
        _userPointsForGraph = await _leaderboardService.getTotalPointsByUserPerDayLast7Days(_userId!);
        notifyListeners();
      }
    }

  }

  Future<void> refreshLeaderboard() async {
    if (_userId != null) {
      await Future.wait([
        _fetchLeaderboardEntries(_userId!),
        _fetchUserPoints(),
        getTotalPointsByUserPerDayLast7Days(),
      ]);
    } else {
      _initializeLeaderboard();
    }
  }
}