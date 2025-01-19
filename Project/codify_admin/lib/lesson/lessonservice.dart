import 'package:cloud_firestore/cloud_firestore.dart';
import 'lesson.dart'; // Import the lesson model

class LessonService {
  final CollectionReference _lessonsCollection =
  FirebaseFirestore.instance.collection('lessons'); // Changed to 'lessons'

  Future<void> addLesson(Lesson lesson) async {
    await _lessonsCollection.add(lesson.toMap());
  }

  Stream<List<Lesson>> getLessons() {
    return _lessonsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Lesson.fromDocument(doc)).toList();
    });
  }

  Future<void> deleteLesson(String documentId) async {
    await _lessonsCollection.doc(documentId).delete();
  }
}