import 'package:cloud_firestore/cloud_firestore.dart';
import 'leaderboard.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addLeaderboardEntry(Leaderboard leaderboard) async {
    await _firestore.collection('leaderboard').add(leaderboard.toMap());
  }

  Future<List<Leaderboard>> getLeaderboardByUserId(String userId) async {
    DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    QuerySnapshot snapshot = await _firestore
        .collection('leaderboard')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: sevenDaysAgo)
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map((doc) => Leaderboard.fromFirestore(doc)).toList();
  }

  Future<List<Leaderboard>> getAllFromLeaderboard() async {
    try {
      final querySnapshot = await _firestore.collection('leaderboard').get();
      return querySnapshot.docs.map((doc) => Leaderboard.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error message $e');
      return [];
    }
  }

  Future<Map<String, int>> getTotalPointsByUserLast7Days() async {
    DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    QuerySnapshot snapshot = await _firestore
        .collection('leaderboard')
        .where('timestamp', isGreaterThanOrEqualTo: sevenDaysAgo)
        .get();

    Map<String, int> userPoints = {};
    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('userId') && data.containsKey('points')) {
        String userId = data['userId'] as String;
        int points = data['points'] as int;
        userPoints[userId] = (userPoints[userId] ?? 0) + points;
      }
    }
    return userPoints;
  }


}