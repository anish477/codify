import 'package:cloud_firestore/cloud_firestore.dart';
import 'lesson.dart';

class LessonService {
  final CollectionReference _lessonsCollection = FirebaseFirestore.instance
      .collection('lessons');


  Future<List<Lesson>> getLessonsByTopicId(String topicId) async {
    try {
      print('getLessonsByTopicId called with topicId: $topicId');
      QuerySnapshot querySnapshot = await _lessonsCollection.where('topicId', isEqualTo: topicId).orderBy("index").get();
      final lessons = querySnapshot.docs.map((doc) => Lesson.fromDocument(doc)).toList();
      print('Lessons fetched: ${lessons.length}');
      return lessons;
    } catch (e) {
      print('Error fetching lessons: $e');
      return [];
    }
  }

}



