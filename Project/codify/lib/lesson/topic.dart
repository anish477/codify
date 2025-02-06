import 'package:cloud_firestore/cloud_firestore.dart';

class Topic {
  final String documentId;
  final String name;
  final String categoryId;
  final List<String> lessonIds;

  Topic({
    required this.documentId,
    required this.name,
    required this.categoryId,
    required this.lessonIds,
  });

  factory Topic.fromDocument(DocumentSnapshot doc) {
    return Topic(
      documentId: doc.id,
      name: doc['name'],
      categoryId: doc['categoryId'],
      lessonIds: List<String>.from(doc['lessonIds']),
    );
  }


}