import 'package:cloud_firestore/cloud_firestore.dart';

class Lives {
  int currentLives;
  DateTime? lastRefillTime;
  final String userId;
  Duration? refillTime; // Changed to Duration?
  String id;

  Lives({
    required this.currentLives,
    required this.userId,
    required this.id,
    this.lastRefillTime,
    this.refillTime,
  });

  // Method to check if a life can be refilled
  bool canRefill() {
    if (currentLives >= 5) {
      return false; // Already at max lives
    }
    if (lastRefillTime == null) {
      return true; // No refill started yet
    }
    final now = DateTime.now();
    final difference = now.difference(lastRefillTime!);
    return difference.inMinutes >= 5; // 5 minutes have passed
  }

  // Method to refill a life
  void refillLife() {
    if (canRefill()) {
      currentLives++;
      lastRefillTime = DateTime.now();
      getNextRefillTime(); // Update refillTime
    }
  }

  // Method to consume a life
  void consumeLife() {
    if (currentLives > 0) {
      currentLives--;
      if (currentLives == 4) {
        lastRefillTime = DateTime.now();
      }
      getNextRefillTime(); // Update refillTime
    }
  }

  // Method to get the time left for the next refill
  Duration? getNextRefillTime() {
    if (currentLives >= 5 || lastRefillTime == null) {
      refillTime = null; // Set refillTime to null when no refill is needed
      return null; // No refill needed or no refill started
    }
    final now = DateTime.now();
    final nextRefill = lastRefillTime!.add(const Duration(minutes: 5));
    final difference = nextRefill.difference(now);
    refillTime = difference;

    return difference;
  }

  // Method to convert Lives to a map for storage
  Map<String, dynamic> toMap() {
    return {
      'currentLives': currentLives,
      'lastRefillTime': lastRefillTime?.toIso8601String(),
      'userId': userId,
    };
  }

  // Method to create Lives from a document
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