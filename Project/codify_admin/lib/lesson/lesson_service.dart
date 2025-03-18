import 'package:cloud_firestore/cloud_firestore.dart';
import 'lesson.dart';

class LessonService {
  final CollectionReference _lessonsCollection = FirebaseFirestore.instance.collection('lessons');

  Future<Lesson?> createLesson(Lesson lesson) async {
    try {
      DocumentReference docRef = await _lessonsCollection.add(lesson.toMap());
      DocumentSnapshot doc = await docRef.get();
      return Lesson.fromDocument(doc);
    } catch (e) {
      print('Error creating lesson: $e');
      return null;
    }
  }

  Future<List<Lesson>> getLessonsByTopicId(String topicId) async {
    try {
      QuerySnapshot querySnapshot = await _lessonsCollection.where('topicId', isEqualTo: topicId).orderBy("index").get();
      return querySnapshot.docs.map((doc) => Lesson.fromDocument(doc)).toList();
    } catch (e) {
      print('Error fetching lessons: $e');
      return [];
    }
  }

  Future<void> updateLesson(Lesson lesson) async {
    try {
      await _lessonsCollection.doc(lesson.documentId).update(lesson.toMap());
    } catch (e) {
      print('Error updating lesson: $e');
    }
  }

  Future<void> deleteLesson(String documentId) async {
    try {
      await _lessonsCollection.doc(documentId).delete();
    } catch (e) {
      print('Error deleting lesson: $e');
    }
  }
}