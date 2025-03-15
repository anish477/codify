import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetail {
  final String documentId;
  final String name;
  final int age;
  final String? userId;
  late final bool hasBeenRedirected;
  final bool profileComplete;

  UserDetail({
    required this.documentId,
    required this.name,
    required this.age,
    required this.userId,
    this.hasBeenRedirected = false,
    this.profileComplete = false,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'userId': userId,
      'hasBeenRedirected': hasBeenRedirected,
      'profileComplete': profileComplete,
    };
  }
}