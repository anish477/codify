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

  // Convert a Lesson object into a map
  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'topicId': topicId,
      'questionName': questionName,
    };
  }

  // Create a Lesson object from a document snapshot
  factory Lesson.fromDocument(DocumentSnapshot doc) {
    return Lesson(
      documentId: doc.id,
      topicId: doc['topicId'],
      questionName: doc['questionName'],
    );
  }


  Lesson copyWith({String? documentId, String? topicId, String? questionName}) {
    return Lesson(
      documentId: documentId ?? this.documentId,
      topicId: topicId ?? this.topicId,
      questionName: questionName ?? this.questionName,
    );
  }
}