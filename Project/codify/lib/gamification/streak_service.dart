import 'package:cloud_firestore/cloud_firestore.dart';

import 'streak.dart';


class StreakDetail{

  final CollectionReference _streakCollection= FirebaseFirestore.instance.collection('streak');

  Future<void> addStreak(Streak streak) async{
    try{
      await _streakCollection.add(streak);

    }catch (e){
      print('$e');
    }

  }

  Future<List<Streak>?> getStreakUserUId(String userUId) async{
    try {
      final querySnapshot= await _streakCollection.where('userId' ,isEqualTo:  userUId).get();
      return querySnapshot.docs
          .map((doc)=> Streak.fromDocument(doc)).toList();

    }catch(e){
      print('Unable to get the user');

    }
    return null;

  }



}