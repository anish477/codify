import "package:codify/user/user_lesson.dart";
import "package:cloud_firestore/cloud_firestore.dart";


class UserLessonService {
  final CollectionReference _userCollection =
  FirebaseFirestore.instance.collection('userLesson');

  Future<List<UserLesson>> getUserLessonByUserId(String userId) async {
    try {
      final querySnapshot = await _userCollection.where('userId', isEqualTo: userId).get();
      return querySnapshot.docs.map((doc) => UserLesson.fromDocument(doc)).toList();
    } catch (e) {
      print("Error fetching user: $e");
      return [];
    }
  }

  Future<void> addUserLesson(UserLesson user) async {
    try {
      await _userCollection.add(user.toMap());
    } catch (e) {
      print("Error adding user: $e");
    }
  }


  Future<void> deleteUserLesson(String documentId) async {
    try {
      await _userCollection.doc(documentId).delete();
    } catch (e) {
      print("Error deleting user lesson: $e");
    }
  }

}