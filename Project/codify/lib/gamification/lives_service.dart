import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'lives.dart';

class LivesService {
  final CollectionReference _livesCollection =
  FirebaseFirestore.instance.collection('lives');
  Lives? _lives;
  Timer? _refillTimer;
  // Use a ValueNotifier to update the UI
  final ValueNotifier<String> _timeRemainingNotifier = ValueNotifier<String>('');
  ValueNotifier<String> get timeRemainingNotifier => _timeRemainingNotifier;

  // Initialize the lives service
  Future<void> init(String userId) async {
    await _loadLives(userId);
    _startRefillTimer();
  }

  // Load lives from Firestore
  Future<void> _loadLives(String userId) async {
    try {
      final querySnapshot = await _livesCollection
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _lives = Lives.fromDocument(querySnapshot.docs.first);
      } else {
        _lives = Lives(
            currentLives: 5,
            userId: userId,
            id: '',
            lastRefillTime: DateTime.now()); // Default to 5 lives
        await _addLives(_lives!);
      }
      _updateTimeRemaining();
    } catch (e) {
      print('Unable to get the user lives: $e');
    }
  }

  // Add lives to firestore
  Future<void> _addLives(Lives lives) async {
    try {
      final docRef = await _livesCollection.add(lives.toMap());
      lives.id = docRef.id;
      await _updateLivesDocument(lives);
    } catch (e) {
      print('$e');
    }
  }

  // Update lives in firestore
  Future<void> _updateLivesDocument(Lives lives) async {
    try {
      await _livesCollection.doc(lives.id).update(lives.toMap());
      _updateTimeRemaining();
    } catch (e) {
      print('Error updating lives document: $e');
    }
  }

  // Start the refill timer
  void _startRefillTimer() {
    _refillTimer?.cancel(); // Cancel any existing timer
    _refillTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lives == null) return;
      if (_lives!.currentLives < 5) {
        // Only refill if not full
        if (_lives!.canRefill()) {
          _lives!.refillLife();
          _updateLivesDocument(_lives!);
        }
      }
      _updateTimeRemaining();
    });
  }

  // Get the current lives
  Lives getLives() {
    if (_lives == null) {
      throw Exception('Lives not initialized. Call init() first.');
    }
    return _lives!;
  }

  // Consume a life
  void consumeLife() {
    if (_lives == null) return;
    if (_lives!.currentLives > 0) {
      _lives!.consumeLife();
      _updateLivesDocument(_lives!);
    }
  }

  // Dispose the timer when the service is no longer needed
  void dispose() {
    _refillTimer?.cancel();
    _timeRemainingNotifier.dispose();
  }

  // Update the time remaining
  void _updateTimeRemaining() {
    if (_lives == null) return;
    if (_lives!.currentLives >= 5) {
      _timeRemainingNotifier.value = 'Lives Full';
      return;
    }
    // Ensure refillTime is updated
    final refillTime = _lives!.getNextRefillTime();

    if (refillTime!.isNegative) {
      _timeRemainingNotifier.value = 'Refilling...';
    } else {
      final minutes = refillTime.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = refillTime.inSeconds.remainder(60).toString().padLeft(2, '0');
      _timeRemainingNotifier.value = '$minutes:$seconds';
    }
  }
}