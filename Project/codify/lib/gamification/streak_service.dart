import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    if (streak == null) {

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
      // Check if streak was already updated today
      final lastUpdatedDate = DateTime.parse(streak.lastUpdated);
      final lastUpdatedDay = DateTime(lastUpdatedDate.year, lastUpdatedDate.month, lastUpdatedDate.day);

      if (lastUpdatedDay.isAtSameMomentAs(startOfToday)) {
        // Already updated today, do nothing
        print('Streak already updated today');
        return;
      }

      final yesterday = startOfToday.subtract(const Duration(days: 1));
      final lastUpdatedIsYesterday = lastUpdatedDay.isAtSameMomentAs(yesterday);

      if (!lastUpdatedIsYesterday && lastUpdatedDay.isBefore(yesterday)) {
        // Streak broken, reset to 0
        print('Streak broken, resetting to 0');
        await _updateStreakDocument(streak.id, 0, DateTime.now(), streak.longestStreak, [DateTime.now()]);
      } else {
        // Streak continues, increment
        print('Streak continues, incrementing');
        final newStreakCount = streak.currentStreak + 1;
        final newLongestStreak = newStreakCount > streak.longestStreak ? newStreakCount : streak.longestStreak;
        final newDates = List<DateTime>.from(streak.dates)..add(DateTime.now());
        await _updateStreakDocument(streak.id, newStreakCount, DateTime.now(), newLongestStreak, newDates);
      }
    }
  }

  Future<void> _updateStreakDocument(String docId, int currentStreak, DateTime lastUpdated, int longestStreak, List<DateTime> dates) async {
    try {
      await _streakCollection.doc(docId).update({
        'currentStreak': currentStreak,
        'lastUpdated': lastUpdated.toIso8601String(),
        'longestStreak': longestStreak,
        'dates': dates.map((date) => date.toIso8601String()).toList(),
      });
    } catch (e) {
      print('Error updating streak document: $e');
    }
  }
}