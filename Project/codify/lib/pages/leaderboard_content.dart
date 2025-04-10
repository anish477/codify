import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../provider/leaderboard_provider.dart';
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
  final UserService _userService = UserService();
  final ImageService _imageService = ImageService();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  bool _isLoading = true;
  Map<String, List<ImageModel>> _userImages = {};
  Map<String, UserDetail> _userDetails = {};
  List<String> _userIds = [];

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    try {
      final leaderboardProvider = Provider.of<LeaderboardProvider>(context, listen: false);
      await leaderboardProvider.refreshLeaderboard();

      Map<String, int> userTotalPoints = leaderboardProvider.userPoints;

      List<MapEntry<String, int>> sortedUserPoints =
      userTotalPoints.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      List<String> sortedUserIds =
      sortedUserPoints.map((entry) => entry.key).toList();

      Map<String, List<ImageModel>> userImages = {};
      Map<String, UserDetail> userDetails = {};

      await Future.wait(sortedUserIds.map((userId) async {
        List<ImageModel> images = await _imageService.getImageByUserId(userId);
        List<UserDetail> details = await _userService.getUserByUserId(userId);
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
          _userIds = sortedUserIds;
          _isLoading = false;
        });
        _refreshController.refreshCompleted();
      }
    } catch (e) {
      print('Error fetching leaderboard: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _refreshController.refreshFailed();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Leaderboard",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      backgroundColor: Color(0xFFFFFFFF),
      body: _isLoading
          ? _buildLoadingShimmer()
          : Consumer<LeaderboardProvider>(
        builder: (context, leaderboardProvider, child) {
          final totalWeeklyPoints = leaderboardProvider.totalWeeklyPoints;
          final wasReset = leaderboardProvider.wasPointsReset;

          return SmartRefresher(
            controller: _refreshController,
            onRefresh: _fetchLeaderboard,
            header: const WaterDropHeader(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Weekly points banner
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF777777),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Your Weekly XP',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                const SizedBox(width: 8),
                                Text(
                                  '$totalWeeklyPoints',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),

                                ),
                                const SizedBox(width: 8),
                                Text("XP",style: TextStyle(fontSize:25,color: Colors.yellow,fontWeight: FontWeight.bold ),)
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Reset notification
                      if (wasReset)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[400]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.refresh_rounded,
                                  color: Colors.green[700]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Your weekly points have been reset!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Top 3 podium
                      if (_userIds.length >= 3)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          child: _buildTopThreePodium(leaderboardProvider),
                        ),
                    ],
                  ),
                ),

                // Leaderboard header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: const [
                        Text(
                          "Leaderboard Rankings",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Leaderboard list
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      // Skip the top 3 users as they are displayed in the podium
                      final listIndex = index;
                      final currentUserId = _userIds[listIndex];
                      final images = _userImages[currentUserId] ?? [];
                      final userDetail = _userDetails[currentUserId];
                      final totalPoints =
                          leaderboardProvider.userPoints[currentUserId] ?? 0;
                      final rank = listIndex + 1;

                      return _buildLeaderboardItem(
                        rank: rank,
                        imageUrl: images.isNotEmpty ? images[0].image : null,
                        username: userDetail?.name ?? 'Unknown User',
                        points: totalPoints,
                      );
                    },
                    childCount: _userIds.length,
                  ),
                ),

                // Add bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopThreePodium(LeaderboardProvider leaderboardProvider) {
    // Ensure we have at least 3 users
    if (_userIds.length < 3) return const SizedBox.shrink();

    // User data for top 3
    final firstUserId = _userIds[0];
    final secondUserId = _userIds[1];
    final thirdUserId = _userIds[2];

    final firstUserImage = _userImages[firstUserId]?.isNotEmpty == true
        ? _userImages[firstUserId]![0].image
        : null;
    final secondUserImage = _userImages[secondUserId]?.isNotEmpty == true
        ? _userImages[secondUserId]![0].image
        : null;
    final thirdUserImage = _userImages[thirdUserId]?.isNotEmpty == true
        ? _userImages[thirdUserId]![0].image
        : null;

    final firstName = _userDetails[firstUserId]?.name ?? 'Unknown';
    final secondName = _userDetails[secondUserId]?.name ?? 'Unknown';
    final thirdName = _userDetails[thirdUserId]?.name ?? 'Unknown';

    final firstPoints = leaderboardProvider.userPoints[firstUserId] ?? 0;
    final secondPoints = leaderboardProvider.userPoints[secondUserId] ?? 0;
    final thirdPoints = leaderboardProvider.userPoints[thirdUserId] ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Second place
        Expanded(
          child: Column(
            children: [
              _buildPodiumAvatar(secondUserImage, 2),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                height: 120,
                width: 100,

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '2',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      secondName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$secondPoints XP',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // First place
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 4),
              _buildPodiumAvatar(firstUserImage, 1),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade300, Colors.amber.shade500],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                height: 150,
                width: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '1',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      firstName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$firstPoints XP',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Third place
        Expanded(
          child: Column(
            children: [
              _buildPodiumAvatar(thirdUserImage, 3),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.orange[200],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                height: 100,
                width: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '3',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      thirdName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$thirdPoints XP',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.brown[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumAvatar(String? imageUrl, int position) {
    final borderColor = position == 1
        ? Color(0xFFFFC300)
        : position == 2
        ? Color(0XFFDDDDDD)
        : Color(0XFFA86425);

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: position == 1 ? 32 : 24,
        backgroundColor: Colors.white,
        backgroundImage: imageUrl != null
            ? NetworkImage(imageUrl)
            : null,
        child: imageUrl == null
            ? Icon(
          Icons.person,
          size: position == 1 ? 32 : 24,
          color: Colors.grey[400],
        )
            : null,
      ),
    );
  }

  Widget _buildLeaderboardItem({
    required int rank,
    String? imageUrl,
    required String username,
    required int points,
  }) {
    if (rank <= 3) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        Container(
          // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  alignment: Alignment.center,
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: rank <= 10 ? Colors.blue[700] : Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                  child: imageUrl == null ? const Icon(Icons.person, color: Colors.grey) : null,
                ),
              ],
            ),
            title: Text(
              username,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$points XP',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ),

          ),


        ),
        SizedBox(height:8)
      ],
    );

  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer for weekly points banner
          Container(
            margin: const EdgeInsets.all(16),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // Shimmer for podium
          Container(
            margin: const EdgeInsets.all(16),
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // Shimmer for leaderboard title
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 24,
            width: 160,
            color: Colors.white,
          ),

          // Shimmer for leaderboard items
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}