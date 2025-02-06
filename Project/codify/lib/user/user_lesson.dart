import 'package:cloud_firestore/cloud_firestore.dart';


class UserLesson {

  final String documentId;
  final String ?userId;
  final String ?userCategoryId;
  final String ?userCategoryName;

  UserLesson(

  {required this.userId,required this.documentId, required this.userCategoryId, required this.userCategoryName

});

  factory UserLesson.fromDocument(DocumentSnapshot doc){
    return UserLesson(
      documentId: doc.id,
      userId: doc['userId'],
      userCategoryId: doc['userCategoryId'],
      userCategoryName: doc['userCategoryName']
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'userId':userId,
      'userCategoryId':userCategoryId,
      'userCategoryName':userCategoryName

    };
  }


}