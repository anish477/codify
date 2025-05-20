import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:codify/gamification/badge.dart' as app_badge;
import 'package:codify/services/auth.dart';
import 'package:codify/pages/badge_provider.dart';

class BadgePage extends StatefulWidget {
  const BadgePage({Key? key}) : super(key: key);

  @override
  _BadgePageState createState() => _BadgePageState();
}

class _BadgePageState extends State<BadgePage> {
  final AuthService _auth = AuthService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initBadges();
  }

  Future<void> _initBadges() async {
    if (!_isInitialized) {
      final badgeProvider = Provider.of<BadgeProvider>(context, listen: false);

      if (badgeProvider.badges.isEmpty && !badgeProvider.isLoading) {
        final userId = await _auth.getUID();
        if (userId != null) {
          await badgeProvider.loadUserBadges(userId);
        }
      }

      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text('My Badges'),
        backgroundColor: const Color(0xFFFFFFFF),
      ),
      body: Consumer<BadgeProvider>(
        builder: (context, badgeProvider, child) {
          if (badgeProvider.isLoading) {
            return _buildShimmerGrid();
          } else if (badgeProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(badgeProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final userId = await _auth.getUID();
                      if (userId != null) {
                        badgeProvider.loadUserBadges(userId);
                      }
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else if (badgeProvider.badges.isEmpty) {
            return const Center(child: Text('No badges earned yet.'));
          } else {
            return _buildBadgesGrid(badgeProvider.badges);
          }
        },
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 10,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadgesGrid(List<app_badge.Badge> badges) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final app_badge.Badge badge = badges[index];
        IconData icon;
        if (badge.badgeType == 'first_lesson') {
          icon = Icons.looks_one;
        } else if (badge.badgeType == 'topic_mastery') {
          icon = Icons.emoji_events;
        } else {
          icon = Icons.star;
        }
        return Card(
          color: Colors.white,
          elevation: 4,
          shadowColor: Colors.grey.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: Colors.amber),
                const SizedBox(height: 8),
                Text(
                  badge.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${badge.dateAwarded.month}/${badge.dateAwarded.day}/${badge.dateAwarded.year}',
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
