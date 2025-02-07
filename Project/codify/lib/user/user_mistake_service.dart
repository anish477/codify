import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_mistake.dart';

class UserMistakeService {
  final CollectionReference _userMistakeCollection = FirebaseFirestore.instance.collection('user_mistakes');

  Future<void> createUserMistake(UserMistake userMistake) async {
    try {
      final querySnapshot = await _userMistakeCollection
          .where('userId', isEqualTo: userMistake.userId)
          .where('mistake', isEqualTo: userMistake.mistake)
          .get();

      if (querySnapshot.docs.isEmpty) {
        await _userMistakeCollection.add(userMistake.toMap());
      } else {
        print('Mistake already exists for this user.');
      }
    } catch (e) {
      print('Error creating user mistake: $e');
    }
  }

  Future<List<UserMistake>> getUserMistakes(String userId) async {
    try {
      final querySnapshot = await _userMistakeCollection.where('userId', isEqualTo: userId).get();
      return querySnapshot.docs.map((doc) => UserMistake.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching user mistakes: $e');
      return [];
    }
  }

  Future<void> deleteUserMistake(String documentId) async {
    try {
      await _userMistakeCollection.doc(documentId).delete();
    } catch (e) {
      print('Error deleting user mistake: $e');
    }
  }


}