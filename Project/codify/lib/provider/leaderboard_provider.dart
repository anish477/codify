import 'dart:async';
import 'package:flutter/material.dart';
import '../gamification/leaderboard_service.dart';
import '../services/auth.dart';
import '../user/image_service.dart';
import '../user/image.dart';
import '../user/user_service.dart';
import '../user/user.dart';

class LeaderboardProvider extends ChangeNotifier {
  final LeaderboardService _leaderboardService = LeaderboardService();
  final AuthService _authService = AuthService();
  final ImageService _imageService = ImageService();
  final UserService _userService = UserService();

  Map<String, int> _userPoints = {};
  int _totalWeeklyPoints = 0;
  bool _wasPointsReset = false;
  String? _userId;
  bool _isLoading = false;
  Map<String, List<ImageModel>> _userImages = {};
  Map<String, UserDetail> _userDetails = {};
  List<String> _userIds = [];
  Timer? _refreshTimer;

  Map<String, int> get userPoints => _userPoints;
  Map<String, int> get userPointsForGraph => _userPoints;
  int get totalWeeklyPoints => _totalWeeklyPoints;
  bool get wasPointsReset => _wasPointsReset;
  bool get isLoading => _isLoading;
  Map<String, List<ImageModel>> get userImages => _userImages;
  Map<String, UserDetail> get userDetails => _userDetails;
  List<String> get userIds => _userIds;
  String? get currentUserId => _userId;

  LeaderboardProvider() {
    refreshLeaderboard();
  
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!_isLoading) {
        refreshLeaderboard(silentRefresh: true);
      }
    });
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

  Future<void> refreshLeaderboard({bool silentRefresh = false}) async {
    if (_isLoading) return;

    if (!silentRefresh) {
      _isLoading = true;
      notifyListeners();
    }

   
    _userId ??= await _authService.getUID();
    if (_userId != null) {
  
      await _fetchUserPoints();
      await getTotalPointsByUserPerDayLast7Days();
     
      final sorted = _userPoints.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      _userIds = sorted.map((e) => e.key).toList();
   
      final imagesMap = <String, List<ImageModel>>{};
      final detailsMap = <String, UserDetail>{};
      await Future.wait(_userIds.map((uid) async {
        final imgs = await _imageService.getImageByUserId(uid);
        final dets = await _userService.getUserByUserId(uid);
        if (dets.isNotEmpty) detailsMap[uid] = dets.first;
        imagesMap[uid] = imgs;
      }));
      _userImages = imagesMap;
      _userDetails = detailsMap;
    }
    _isLoading = false;
    notifyListeners();
  }


  void refreshAfterPointsUpdate() {
    refreshLeaderboard();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
