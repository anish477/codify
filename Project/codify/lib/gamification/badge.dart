import 'package:cloud_firestore/cloud_firestore.dart';

class Badge {
  final String id;
  final String userId;
  final String topicId;
  final String badgeType;
  final String name;
  final String description;
  final DateTime dateAwarded;

  Badge({
    required this.id,
    required this.userId,
    required this.topicId,
    required this.badgeType,
    required this.name,
    required this.description,
    required this.dateAwarded,
  });

  factory Badge.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Badge(
      id: doc.id,
      userId: data['userId'],
      topicId: data['topicId'],
      badgeType: data['badgeType'],
      name: data['name'],
      description: data['description'],
      dateAwarded: (data['dateAwarded'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'topicId': topicId,
      'badgeType': badgeType,
      'name': name,
      'description': description,
      'dateAwarded': Timestamp.fromDate(dateAwarded),
    };
  }
}
