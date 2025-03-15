import "package:codify/user/image.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageService {
  final CollectionReference _userCollection =
  FirebaseFirestore.instance.collection('images');

  Future<List<ImageModel>> getImageByUserId(String userId) async {
    try {
      final querySnapshot = await _userCollection.where('userId', isEqualTo: userId).get();
      return querySnapshot.docs.map((doc) => ImageModel.fromDocument(doc)).toList();
    } catch (e) {
      print("Error fetching user: $e");
      return [];
    }
  }

  Future<void> addImage(ImageModel user) async {
    try {
      await _userCollection.add(user.toMap());
    } catch (e) {
      print("Error adding user: $e");
    }
  }

  Future<void> updateImage(String documentId, Map<String, dynamic> data) async {
    try {
      await _userCollection.doc(documentId).update(data);
    } catch (e) {
      print("Error updating image: $e");
    }
  }

}