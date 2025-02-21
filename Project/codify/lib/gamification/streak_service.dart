import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'streak.dart';

class StreakService {
  final CollectionReference _streakCollection =
  FirebaseFirestore.instance.collection('streak');

  String _getCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }

  Future<void> addStreak(Streak streak) async {
    try {
      await _streakCollection.add(streak.toMap());
    } catch (e) {
      print('$e');
    }
  }

  Future<Streak?> getStreakForUser(String userId) async {
    try {
      final querySnapshot = await _streakCollection
          .where('userId', isEqualTo: userId)
          .orderBy('lastUpdated', descending: true) // Get the most recent streak
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Streak.fromDocument(querySnapshot.docs.first);
      } else {
        return null; // No streak found for the user
      }
    } catch (e) {
      print('Unable to get the user streak: $e');
      return null;
    }
  }

  Future<void> updateStreak(String userId) async {
    final currentDate = _getCurrentDate();
    final streak = await getStreakForUser(userId);

    if (streak == null) {
      // No existing streak, create a new one
      final newStreak = Streak(
        id: '',
        userId: userId,
        currentStreak: 1,
        longestStreak: 1,
        lastUpdated: currentDate,
        dates: [DateTime.now()],
      );
      await addStreak(newStreak);
    } else {
      // Streak exists, check if it needs to be updated or reset
      if (streak.lastUpdated == currentDate) {
        // User already updated the streak today, do nothing
        print('User already updated the streak today');
        return;
      }

      final lastUpdatedDate = DateTime.parse(streak.lastUpdated);
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      if (lastUpdatedDate.isBefore(yesterday)) {
        // Streak broken, reset to 1
        print('Streak broken, resetting to 1');
        await _updateStreakDocument(streak.id, 1, currentDate, streak.longestStreak, [DateTime.now()]);
      } else {
        // Streak continues, increment
        print('Streak continues, incrementing');
        final newStreakCount = streak.currentStreak + 1;
        final newLongestStreak =
        newStreakCount > streak.longestStreak ? newStreakCount : streak.longestStreak;
        final newDates = List<DateTime>.from(streak.dates)..add(DateTime.now());
        await _updateStreakDocument(streak.id, newStreakCount, currentDate, newLongestStreak, newDates);
      }
    }
  }

  Future<void> _updateStreakDocument(String docId, int currentStreak, String lastUpdated, int longestStreak, List<DateTime> dates) async {
    try {
      await _streakCollection.doc(docId).update({
        'currentStreak': currentStreak,
        'lastUpdated': lastUpdated,
        'longestStreak': longestStreak,
        'dates': dates.map((date) => date.toIso8601String()).toList(),
      });
    } catch (e) {
      print('Error updating streak document: $e');
    }
  }
}