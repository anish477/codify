import 'package:cloud_firestore/cloud_firestore.dart';

class ImageModel {
  final image;
  final documentId;
  final userId;

  ImageModel({required this.image, required this.documentId, required this.userId});

  factory ImageModel.fromDocument(DocumentSnapshot doc){
    final data=doc.data() as Map<String,dynamic>;
    return ImageModel(image: data['image'], documentId: doc.id, userId: data['userId']);


  }


  Map<String,dynamic> toMap(){

    return{
      'image':image,
      'userId':userId

    };
  }



}