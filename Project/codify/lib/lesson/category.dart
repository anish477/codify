import 'package:cloud_firestore/cloud_firestore.dart';
class Category {
  final String documentId;
  final String name;
  final List<String> lessonIds;

  Category({required this.documentId, required this.name, required this.lessonIds});

  factory Category.fromDocument(DocumentSnapshot doc) {
    return Category(
      documentId: doc.id,
      name: doc['name'],
      lessonIds: List<String>.from(doc['lessonIds']),
    );
  }
  }

