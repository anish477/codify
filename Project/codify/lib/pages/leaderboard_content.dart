import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../provider/leaderboard_provider.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with AutomaticKeepAliveClientMixin<LeaderboardPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<LeaderboardProvider>(context, listen: false);
      if (provider.userIds.isEmpty) _onRefresh();
    });
  }

  Future<void> _onRefresh() async {
    await Provider.of<LeaderboardProvider>(context, listen: false)
        .refreshLeaderboard();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = context.watch<LeaderboardProvider>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Leaderboard",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: provider.isLoading
          ? _buildLoadingShimmer()
          : SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              header: const WaterDropHeader(),
              child: ListView(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF777777),
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
                              '${provider.totalWeeklyPoints}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "XP",
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (provider.wasPointsReset)
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
                          Icon(Icons.refresh_rounded, color: Colors.green[700]),
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
                  if (provider.userIds.length >= 3)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      child: _buildTopThreePodium(provider),
                    ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 24, 16, 8),
                    child: Text(
                      "Leaderboard Rankings",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  ...List.generate(provider.userIds.length, (index) {
                    final currentUserId = provider.userIds[index];
                    final myId = provider.currentUserId;
                    final isMe = currentUserId == myId;
                    final images = provider.userImages[currentUserId] ?? [];
                    final userDetail = provider.userDetails[currentUserId];
                    final totalPoints = provider.userPoints[currentUserId] ?? 0;
                    final rank = index + 1;

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 1),
                      child: _buildLeaderboardItem(
                        rank: rank,
                        imageUrl: images.isNotEmpty ? images[0].image : null,
                        username: userDetail?.name ?? 'Unknown User',
                        points: totalPoints,
                        isMe: isMe,
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildTopThreePodium(LeaderboardProvider leaderboardProvider) {
    final myId = leaderboardProvider.currentUserId;

    if (leaderboardProvider.userIds.length < 3) return const SizedBox.shrink();

    final firstUserId = leaderboardProvider.userIds[0];
    final secondUserId = leaderboardProvider.userIds[1];
    final thirdUserId = leaderboardProvider.userIds[2];

    final firstUserImage =
        leaderboardProvider.userImages[firstUserId]?.isNotEmpty == true
            ? leaderboardProvider.userImages[firstUserId]![0].image
            : null;
    final secondUserImage =
        leaderboardProvider.userImages[secondUserId]?.isNotEmpty == true
            ? leaderboardProvider.userImages[secondUserId]![0].image
            : null;
    final thirdUserImage =
        leaderboardProvider.userImages[thirdUserId]?.isNotEmpty == true
            ? leaderboardProvider.userImages[thirdUserId]![0].image
            : null;

    final firstName =
        leaderboardProvider.userDetails[firstUserId]?.name ?? 'Unknown';
    final secondName =
        leaderboardProvider.userDetails[secondUserId]?.name ?? 'Unknown';
    final thirdName =
        leaderboardProvider.userDetails[thirdUserId]?.name ?? 'Unknown';

    final firstPoints = leaderboardProvider.userPoints[firstUserId] ?? 0;
    final secondPoints = leaderboardProvider.userPoints[secondUserId] ?? 0;
    final thirdPoints = leaderboardProvider.userPoints[thirdUserId] ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
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
                  border: Border.all(
                    color: secondUserId == myId
                        ? Colors.yellowAccent
                        : Colors.transparent,
                    width: 3,
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
                child: const Icon(Icons.emoji_events,
                    color: Colors.white, size: 24),
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
                  border: Border.all(
                    color: firstUserId == myId
                        ? Colors.yellowAccent
                        : Colors.transparent,
                    width: 3,
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
                  border: Border.all(
                    color: thirdUserId == myId
                        ? Colors.yellowAccent
                        : Colors.transparent,
                    width: 3,
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
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
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
    required bool isMe,
  }) {
    if (rank <= 3) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isMe ? Colors.amber.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isMe ? Colors.yellowAccent : Colors.transparent,
              width: 2,
            ),
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  backgroundImage:
                      imageUrl != null ? NetworkImage(imageUrl) : null,
                  child: imageUrl == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
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
        SizedBox(height: 8)
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
          Container(
            margin: const EdgeInsets.all(16),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 24,
            width: 160,
            color: Colors.white,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
