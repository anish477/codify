import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
  // Future<Map<String, int>> getTotalPointsByUserPerDayLast7Days(String userId) async {
  //   DateTime now = DateTime.now();
  //   Map<String, int> dailyPoints = {};
  //
  //   for (int i = 0; i < 7; i++) {
  //     DateTime dayStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
  //     DateTime dayEnd = dayStart.add(Duration(days: 1));
  //
  //     QuerySnapshot snapshot = await _firestore
  //         .collection('leaderboard')
  //         .where('userId', isEqualTo: userId)
  //         .where('timestamp', isGreaterThanOrEqualTo: dayStart)
  //         .where('timestamp', isLessThan: dayEnd)
  //         .get();
  //
  //     int totalPoints = 0;
  //     for (var doc in snapshot.docs) {
  //       var data = doc.data() as Map<String, dynamic>;
  //       if (data.containsKey('points')) {
  //         totalPoints += data['points'] as int;
  //       }
  //     }
  //     dailyPoints[DateFormat('yyyy-MM-dd').format(dayStart)] = totalPoints;
  //   }
  //
  //   return dailyPoints;
  // }

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

    QuerySnapshot snapshot = await _firestore
        .collection('leaderboard')
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

    DocumentReference resetRef = _firestore.collection('pointsResetTracker').doc(userId);


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