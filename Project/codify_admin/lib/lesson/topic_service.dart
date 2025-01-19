import 'package:cloud_firestore/cloud_firestore.dart';
import 'topic.dart';


class TopicService {
  final CollectionReference _topicsCollection =
  FirebaseFirestore.instance.collection('Topics');

  // Create a new topic
  Future<Topic?> createTopic(Topic topic) async {
    try {
      final docRef = await _topicsCollection.add(topic.toMap());
      final docSnapshot = await docRef.get();
      return Topic.fromDocument(docSnapshot);
    } catch (e) {
      print('Error creating topic: $e');
      return null;
    }
  }

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
      final querySnapshot = await _topicsCollection.get();
      return querySnapshot.docs
          .map((doc) => Topic.fromDocument(doc))
          .toList();
    } catch (e) {
      print('Error getting all topics: $e');
      return [];
    }
  }
  Stream<List<Topic>> getTopicsStreamByLessonId(String lessonId) {
    return _topicsCollection
        .where('lessonIds', arrayContains: lessonId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Topic.fromDocument(doc)).toList();
    });
  }

  // Update a topic
  Future<Topic?> updateTopic(Topic topic) async {
    try {
      final docRef = _topicsCollection.doc(topic.documentId);
      await docRef.update(topic.toMap());
      final docSnapshot = await docRef.get();
      return Topic.fromDocument(docSnapshot);
    } catch (e) {
      print('Error updating topic: $e');
      return null;
    }
  }

  // Delete a topic
  Future<void> deleteTopic(String topicId) async {
    try {
      await _topicsCollection.doc(topicId).delete();
    } catch (e) {
      print('Error deleting topic: $e');
    }
  }

  // Add a lesson to a topic
  Future<void> addLessonToTopic(String topicId, String lessonId) async {
    try {
      final topicDoc = await _topicsCollection.doc(topicId).get();
      if (topicDoc.exists) {
        final topic = Topic.fromDocument(topicDoc);
        topic.lessonIds.add(lessonId);
        await _topicsCollection.doc(topicId).update({'lessonIds': topic.lessonIds});
      } else {
        print('Topic not found');
      }
    } catch (e) {
      print('Error adding lesson to topic: $e');
    }
  }
}