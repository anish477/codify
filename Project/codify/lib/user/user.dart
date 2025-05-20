import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetail {
  final String documentId;
  final String name;
  final int age;
  final String? userId;
  late final bool hasBeenRedirected;
  final bool profileComplete;
  String? fcmToken;
  final bool isBlacklisted;
  final String? blacklistReason;

  UserDetail({
    required this.documentId,
    required this.name,
    required this.age,
    required this.userId,
    this.hasBeenRedirected = false,
    this.profileComplete = false,
    required this.fcmToken,
    this.isBlacklisted = false,
    this.blacklistReason,
  });

  factory UserDetail.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserDetail(
      documentId: doc.id,
      name: data['name'],
      age: data['age'],
      userId: data['userId'],
      hasBeenRedirected: data['hasBeenRedirected'] ?? false,
      profileComplete: data['profileComplete'] ?? false,
      fcmToken: data['fcmToken'],
      isBlacklisted: data['isBlacklisted'] ?? false,
      blacklistReason: data['blacklistReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'userId': userId,
      'hasBeenRedirected': hasBeenRedirected,
      'profileComplete': profileComplete,
      'fcmToken': fcmToken,
      'isBlacklisted': isBlacklisted,
      'blacklistReason': blacklistReason,
    };
  }
}
