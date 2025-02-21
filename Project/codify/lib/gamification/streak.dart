import 'package:cloud_firestore/cloud_firestore.dart';

class Streak {
  final String id;
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final String lastUpdated;
  final List<DateTime> dates;

  Streak({
    required this.id,
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastUpdated,
    required this.dates,
  });

  factory Streak.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Streak(
      id: doc.id,
      userId: data['userId'] as String,
      currentStreak: data['currentStreak'] as int,
      longestStreak: data['longestStreak'] as int,
      lastUpdated: data['lastUpdated'] as String,
      dates: (data['dates'] as List<dynamic>?)
          ?.map((date) => DateTime.parse(date as String))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastUpdated': lastUpdated,
      'dates': dates.map((date) => date.toIso8601String()).toList(),
    };
  }
}