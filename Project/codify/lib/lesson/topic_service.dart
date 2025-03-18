import 'package:cloud_firestore/cloud_firestore.dart';
import 'topic.dart';


class TopicService {
  final CollectionReference _topicsCollection =
  FirebaseFirestore.instance.collection('Topics');

  // Get a topic by ID
  Future<Topic?> getTopicById(String topicId) async {
    try {
      final docSnapshot = await _topicsCollection.doc(topicId).get();
      if (docSnapshot.exists) {
        return Topic.fromDocument(docSnapshot);
      } else {
        print('Topic not found');
        return null;
      }
    } catch (e) {
      print('Error getting topic: $e');
      return null;
    }
  }
  // Get all topics
  Future<List<Topic>> getAllTopics() async {
    try {
      final querySnapshot = await _topicsCollection.orderBy('index').get();
      return querySnapshot.docs
          .map((doc) => Topic.fromDocument(doc))
          .toList();
    } catch (e) {
      print('Error getting all topics: $e');
      return [];
    }
  }




}