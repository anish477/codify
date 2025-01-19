import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final CollectionReference _userCollection =
  FirebaseFirestore.instance.collection("users");


  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      QuerySnapshot querySnapshot = await _userCollection.get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      // Handle exceptions here
      print("Error retrieving all users: $e");
      return [];
    }
  }
}