import 'package:cloud_firestore/cloud_firestore.dart';



class Leaderboard {
  final String userId;
  final int points;
  final  DateTime  timestamp;
  final String documentId;

  Leaderboard({
    required this.userId,
    required this.points,
    required this.timestamp,
    required this.documentId,
  });

  factory Leaderboard.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Leaderboard(
      userId: data['userId'],
      points: data['points'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      documentId: doc.id,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'points': points,
      'timestamp': timestamp,
    };
  }

}
