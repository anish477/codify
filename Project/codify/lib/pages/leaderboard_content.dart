import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../gamification/leaderboard_service.dart';
import '../services/auth.dart';
import '../user/user_service.dart';
import "../user/image_service.dart";
import "../user/image.dart";
import "../user/user.dart";

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final LeaderboardService _leaderboardService = LeaderboardService();
  final AuthService _auth = AuthService();
  final UserService _userService = UserService();
  final ImageService _imageService = ImageService();
  bool _isLoading = true;
  Map<String, List<ImageModel>> _userImages = {};
  Map<String, UserDetail> _userDetails = {};
  Map<String, int> _userTotalPoints = {};
  List<String> _userIds = [];

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    try {
      final String? userId = await _auth.getUID();
      if (userId != null) {
        Map<String, int> userTotalPoints =
        await _leaderboardService.getTotalPointsByUserLast7Days();

        List<MapEntry<String, int>> sortedUserPoints =
        userTotalPoints.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        List<String> sortedUserIds =
        sortedUserPoints.map((entry) => entry.key).toList();

        Map<String, List<ImageModel>> userImages = {};
        Map<String, UserDetail> userDetails = {};

        // Fetch user details and images concurrently
        await Future.wait(sortedUserIds.map((userId) async {
          List<ImageModel> images =
          await _imageService.getImageByUserId(userId);
          List<UserDetail> details =
          await _userService.getUserByUserId(userId);
          if (details.isNotEmpty) {
            if (mounted) {
              userDetails[userId] = details[0];
            }
          }
          if (mounted) {
            userImages[userId] = images;
          }
        }));

        if (mounted) {
          setState(() {
            _userImages = userImages;
            _userDetails = userDetails;
            _userTotalPoints = userTotalPoints;
            _userIds = sortedUserIds;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching leaderboard: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        title: const Text("Leaderboard"),
      ),
      backgroundColor: Color(0xFFFFFFFF),
      body: _isLoading
          ? Center(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: [
              Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  color: Colors.blue,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 100,
                          height: 20,
                          color: Colors.grey[300],
                        ),
                        const Icon(Icons.arrow_downward,
                            color: Colors.white),
                      ])),
              Expanded(
                  child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Container(
                            height: 16,
                            width: 100,
                            color: Colors.grey[300],
                          ),
                          subtitle: Container(
                            height: 10,
                            width: 80,
                            color: Colors.grey[300],
                          ),
                        );
                      }))
            ],
          ),
        ),
      )
          : ListView.builder(
        itemCount: _userIds.length,
        itemBuilder: (context, index) {
          final currentUserId = _userIds[index];
          final images = _userImages[currentUserId] ?? [];
          final userDetail = _userDetails[currentUserId];
          final totalPoints = _userTotalPoints[currentUserId] ?? 0;
          final rank = index + 1; // Calculate the rank

          Color? backgroundColor;
          if (rank == 1) {
            backgroundColor = Colors.yellow[200];
          } else if (rank == 2) {
            backgroundColor = Colors.grey[300];
          } else if (rank == 3) {
            backgroundColor = Colors.orange[200];
          }

          return Card(
            color: backgroundColor,
            margin:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: images.isNotEmpty
                  ? CircleAvatar(
                backgroundImage: NetworkImage(images[0].image),
              )
                  : const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(userDetail?.name ?? 'Unknown User'),
              trailing: Text('$totalPoints Xp'),
              subtitle: Text('Rank: $rank'),
            ),
          );
        },
      ),
    );
  }
}