import 'package:cloud_firestore/cloud_firestore.dart';

class UserStatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> markQuestionAsComplete(String userId, String topicId, String questionId) async {
    try {
      DocumentReference userStatDoc = _firestore.collection('userStats').doc(userId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userStatDoc);

        if (!snapshot.exists) {
          transaction.set(userStatDoc, {
            'userId': userId,
            'topicId': topicId,
            'questionIds': [questionId],
            'isComplete': true,
            'timestamp': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.update(userStatDoc, {
            'questionIds': FieldValue.arrayUnion([questionId]),
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('Error marking question as complete: $e');
    }

  }
  Future<List<String>> getUserStats(String userId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('userStats').doc(userId).get();
      if (snapshot.exists) {
        List<dynamic> questionIds = snapshot.get('questionIds');
        return List<String>.from(questionIds);
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting user stats: $e');
      return [];
    }
  }

}