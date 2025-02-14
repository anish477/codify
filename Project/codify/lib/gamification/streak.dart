
import 'package:cloud_firestore/cloud_firestore.dart';

class Streak {

  final String documentId;
  final String userId;
  final streakCount;

  Streak({
    required this.userId,required this.documentId, required this.streakCount
});

  factory Streak.fromDocument(DocumentSnapshot doc){
    final data=doc.data() as Map<String, dynamic>;
    return Streak (
      documentId:doc.id,
      streakCount: 'streakCount',
      userId: 'userId',
    );
  }
  Map<String, dynamic> toMap(){
    return {
      'streakCount':streakCount,
      'usrId':userId
    };
  }

}


