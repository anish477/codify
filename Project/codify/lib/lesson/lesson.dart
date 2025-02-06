

import 'package:cloud_firestore/cloud_firestore.dart';

class Lesson {
  final String documentId;
  final String topicId;
  final String questionName;

  Lesson({
    required this.documentId,
    required this.topicId,
    required this.questionName,
  });

  factory Lesson.fromDocument(DocumentSnapshot doc) {
    return Lesson(
      documentId: doc.id,
      topicId: doc['topicId'],
      questionName: doc['questionName'],
    );
  }
}
