import 'package:cloud_firestore/cloud_firestore.dart';

class Topic {
  final String documentId;
  final String name;
  final String categoryId; // Added categoryId field
  final List<String> lessonIds;

  Topic({
    required this.documentId,
    required this.name,
    required this.categoryId, // Added categoryId parameter
    required this.lessonIds,
  });

  factory Topic.fromDocument(DocumentSnapshot doc) {
    return Topic(
      documentId: doc.id,
      name: doc['name'],
      categoryId: doc['categoryId'], // Added categoryId to fromDocument
      lessonIds: List<String>.from(doc['lessonIds']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'categoryId': categoryId, // Added categoryId to map
      'lessonIds': lessonIds,
    };
  }

  Topic copyWith({String? documentId, String? name, String? categoryId, List<String>? lessonIds}) {
    return Topic(
      documentId: documentId ?? this.documentId,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      lessonIds: lessonIds ?? this.lessonIds,
    );
  }
}