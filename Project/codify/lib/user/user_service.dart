import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';

class UserService {
  final CollectionReference _userCollection =
  FirebaseFirestore.instance.collection('users');

  Future<List<UserDetail>> getUserByUserId(String userId) async {
    try {
      final querySnapshot =
      await _userCollection.where('userId', isEqualTo: userId).get();
      return querySnapshot.docs
          .map((doc) => UserDetail.fromDocument(doc))
          .toList();
    } catch (e) {
      print("Error fetching user: $e");
      throw Exception("Error fetching user: $e");
    }
  }

  Stream<List<UserDetail>> getUserStreamByUserId(String userId) {
    return _userCollection.where('userId', isEqualTo: userId).snapshots().map(
            (snapshot) => snapshot.docs
            .map((doc) => UserDetail.fromDocument(doc))
            .toList());
  }

  Future<void> addUser(UserDetail user) async {
    try {
      await _userCollection.add(user.toMap());
    } catch (e) {
      print("Error adding user: $e");
      throw Exception("Error adding user: $e");
    }
  }

  Future<void> updateUser(UserDetail user) async {
    try {
      final querySnapshot = await _userCollection
          .where('userId', isEqualTo: user.userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;
        await _userCollection.doc(docId).update(user.toMap());
      } else {
        throw Exception("User not found with userId: ${user.userId}");
      }
    } catch (e) {
      print("Error updating user: $e");
      throw Exception("Error updating user: $e");
    }
  }

  // Future<UserDetail?> getUserByUserIdRedirect(String userId) async {
  //   final querySnapshot = await _userCollection
  //       .where('userId', isEqualTo: userId)
  //       .where('hasBeenRedirected', isEqualTo: false)
  //       .get();
  //
  //   if (querySnapshot.docs.isNotEmpty) {
  //     return UserDetail.fromDocument(querySnapshot.docs.first);
  //   } else {
  //     return null;
  //   }
  // }



}