import "package:cloud_firestore/cloud_firestore.dart";
import 'leaderboard.dart';
class LeaderboardService{

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Leaderboard>> getLeaderboard() async {
    QuerySnapshot snapshot = await _firestore.collection('leaderboard').orderBy('points', descending: true).get();
    return snapshot.docs.map((doc) {
      return Leaderboard.fromFirestore(doc);
    }).toList();
  }


  Future<void> addLeaderboardEntry(Leaderboard leaderboard) async {
    await _firestore.collection('leaderboard').add(leaderboard.toMap());
  }

}