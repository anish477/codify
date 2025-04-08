import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'leaderboard.dart';

class LeaderboardService {

  final CollectionReference _leaderboardCollection =FirebaseFirestore.instance.collection('leaderboard');

  Future<void> addLeaderboardEntry(Leaderboard leaderboard) async {
    await _leaderboardCollection.add(leaderboard.toMap());
  }

  Future<List<Leaderboard>> getLeaderboardByUserId(String userId) async {
    DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    QuerySnapshot snapshot = await _leaderboardCollection
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: sevenDaysAgo)
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map((doc) => Leaderboard.fromFirestore(doc)).toList();
  }

  Future<List<Leaderboard>> getAllFromLeaderboard() async {
    try {
      final querySnapshot = await _leaderboardCollection.get();
      return querySnapshot.docs.map((doc) => Leaderboard.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error message $e');
      return [];
    }
  }
  Future<Map<String, int>> getUserPointsByDay(String userId) async {
    Map<String, int> dailyPoints = {};
    try {
      // Get current date
      final now = DateTime.now();
      // Calculate date 7 days ago
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      // Query points for this user in the last 7 days
      final pointsRef = FirebaseFirestore.instance.collection('leaderboard');
      final querySnapshot = await pointsRef
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
          .orderBy('timestamp')
          .get();

      // Group points by day
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final timestamp = data['timestamp'] as Timestamp;
        final points = data['points'] as int;

        // Format date to YYYY-MM-DD
        final date = timestamp.toDate();
        final dateStr = DateFormat('yyyy-MM-dd').format(date);

        // Add points to the appropriate day
        if (dailyPoints.containsKey(dateStr)) {
          dailyPoints[dateStr] = dailyPoints[dateStr]! + points;
        } else {
          dailyPoints[dateStr] = points;
        }
      }

      // Fill in missing days with zero points
      for (int i = 6; i >= 0; i--) {
        final date = DateTime.now().subtract(Duration(days: i));
        final dateStr = DateFormat('yyyy-MM-dd').format(date);

        dailyPoints.putIfAbsent(dateStr, () => 0);
      }
    } catch (e) {
      print('Error fetching user daily points: $e');
    }

    return dailyPoints;
  }

  Future<Map<String, int>> getTotalPointsByUserLast7Days() async {
    DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    QuerySnapshot snapshot = await _leaderboardCollection
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


  Future<Map<String, dynamic>> getWeeklyPointsWithReset(String userId) async {

    bool wasReset = await _checkAndResetWeeklyPoints(userId);


    int totalPoints = await _getTotalPointsForPast7Days(userId);

    return {
      'totalPoints': totalPoints,
      'wasReset': wasReset
    };
  }


  Future<int> _getTotalPointsForPast7Days(String userId) async {
    DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    QuerySnapshot snapshot = await _leaderboardCollection
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: sevenDaysAgo)
        .get();

    int totalPoints = 0;
    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('points')) {
        totalPoints += data['points'] as int;
      }
    }

    return totalPoints;
  }


  Future<bool> _checkAndResetWeeklyPoints(String userId) async {

    DocumentReference resetRef = FirebaseFirestore.instance.collection('pointsResetTracker').doc(userId);


    DocumentSnapshot resetDoc = await resetRef.get();
    DateTime now = DateTime.now();

    if (!resetDoc.exists) {

      await resetRef.set({
        'lastResetDate': now,
        'userId': userId
      });
      return false;
    } else {

      Map<String, dynamic> data = resetDoc.data() as Map<String, dynamic>;
      DateTime lastReset = (data['lastResetDate'] as Timestamp).toDate();
      Duration difference = now.difference(lastReset);

      if (difference.inDays >= 7) {

        await resetRef.update({'lastResetDate': now});
        return true;
      }

      return false;
    }
  }

}