import 'package:cloud_firestore/cloud_firestore.dart';
import 'lesson.dart';

class LessonService {
  final CollectionReference _lessonsCollection = FirebaseFirestore.instance
      .collection('lessons');


  Future<List<Lesson>> getLessonsByTopicId(String topicId) async {
    try {
      QuerySnapshot querySnapshot = await _lessonsCollection.where(
          'topicId', isEqualTo: topicId).get();
      return querySnapshot.docs.map((doc) => Lesson.fromDocument(doc)).toList();
    } catch (e) {
      print('Error fetching lessons: $e');
      return [];

    }
  }

}



