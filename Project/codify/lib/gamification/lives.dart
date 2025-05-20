import 'package:cloud_firestore/cloud_firestore.dart';

class Lives {
  int currentLives;
  DateTime? lastRefillTime;
  final String userId;
  Duration? refillTime; 
  String id;

  Lives({
    required this.currentLives,
    required this.userId,
    required this.id,
    this.lastRefillTime,
    this.refillTime,
  });

  bool canRefill() {
    if (currentLives >= 5) {
      return false; 
    }
    if (lastRefillTime == null) {
      return true;
    }
    final now = DateTime.now();
    final difference = now.difference(lastRefillTime!);
    return difference.inMinutes >= 5; 
  }


  void refillLife() {
    if (canRefill()) {
      currentLives++;
      lastRefillTime = DateTime.now();
      getNextRefillTime(); 
    }
  }


  void consumeLife() {
    if (currentLives > 0) {
      currentLives--;
      if (currentLives == 4) {
        lastRefillTime = DateTime.now();
      }
      getNextRefillTime(); 
    }
  }


  Duration? getNextRefillTime() {
    if (currentLives >= 5 || lastRefillTime == null) {
      refillTime = null; 
      return null; 
    }
    final now = DateTime.now();
    final nextRefill = lastRefillTime!.add(const Duration(minutes: 5));
    final difference = nextRefill.difference(now);
    refillTime = difference;

    return difference;

  }


  Map<String, dynamic> toMap() {
    return {
      'currentLives': currentLives,
      'lastRefillTime': lastRefillTime?.toIso8601String(),
      'userId': userId,
    };
  }

  static Lives fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Lives(
      currentLives: data['currentLives'] as int,
      lastRefillTime: data['lastRefillTime'] != null
          ? DateTime.parse(data['lastRefillTime'] as String)
          : null,
      userId: data['userId'] as String,
      id: doc.id,
    );
  }
}