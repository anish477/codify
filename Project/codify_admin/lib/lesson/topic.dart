import 'package:cloud_firestore/cloud_firestore.dart';

class Topic {
  final String documentId;
  final String name;
  final String categoryId;
  final List<String> lessonIds;
  final String index;

  Topic({
    required this.documentId,
    required this.name,
    required this.categoryId, // Added categoryId parameter
    required this.lessonIds,
    required this.index,
  });

  factory Topic.fromDocument(DocumentSnapshot doc) {
    return Topic(
      documentId: doc.id,
      name: doc['name'],
      categoryId: doc['categoryId'], // Added categoryId to fromDocument
      lessonIds: List<String>.from(doc['lessonIds']),
      index: doc['index'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'categoryId': categoryId, // Added categoryId to map
      'lessonIds': lessonIds,
      'index': index,
    };
  }

  Topic copyWith({String? documentId, String? name, String? categoryId, List<String>? lessonIds,  String? index}) {
    return Topic(
      documentId: documentId ?? this.documentId,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      lessonIds: lessonIds ?? this.lessonIds,
      index: index ?? this.index,
    );
  }
}