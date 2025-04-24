import 'package:flutter/material.dart';
import 'package:codify/services/auth.dart';
import 'package:codify/pages/profile.dart';
import 'package:codify/pages/training.dart';
import 'package:codify/pages/leaderboard_content.dart';
import 'package:codify/pages/lesson_main.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:codify/services/notification_service.dart';
import 'package:codify/gamification/streak_service.dart';
import 'package:codify/gamification/streak.dart';
import 'package:flutter/foundation.dart';
import '../gamification/blockly.dart';

void main() => runApp(const MaterialApp(
      home: Home(),
    ));

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  final NotificationService _notificationService = NotificationService();
  final StreakService _streakService = StreakService();
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _scheduleStreakReminder();
  }

  TimeOfDay? _calculateAverageTime(List<DateTime> dates) {
    if (dates.isEmpty) return null;

    double totalSecondsPastMidnight = 0;
    for (var date in dates) {
      totalSecondsPastMidnight +=
          date.hour * 3600 + date.minute * 60 + date.second;
    }

    final averageSecondsPastMidnight =
        (totalSecondsPastMidnight / dates.length).round();

    final averageHour = averageSecondsPastMidnight ~/ 3600;
    final averageMinute = (averageSecondsPastMidnight % 3600) ~/ 60;

    return TimeOfDay(hour: averageHour, minute: averageMinute);
  }

  Future<void> _scheduleStreakReminder() async {
    final String? userId = await _auth.getUID();
    if (userId == null) {
      print("[Streak Reminder] User not logged in. Cannot schedule reminder.");
      return;
    }

    final Streak? streak = await _streakService.getStreakForUser(userId);
    const int reminderId = 101;

    await _notificationService.cancelScheduledNotification(reminderId);
    // print(
    //     "[Streak Reminder] Cancelled any existing reminder with ID $reminderId.");

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    bool needsReminder = true;
    DateTime? lastActivityTime;
    List<DateTime> recentDates = [];

    if (streak != null && streak.dates.isNotEmpty) {
      // Sort dates just in case
      streak.dates.sort();
      lastActivityTime = streak.dates.last;

      // Check if active today
      final lastActivityDay = DateTime(
          lastActivityTime.year, lastActivityTime.month, lastActivityTime.day);
      if (lastActivityDay.isAtSameMomentAs(today)) {
        needsReminder = false;
        // print(
        //     "[Streak Reminder] Streak activity recorded today ($lastActivityTime). No reminder needed.");
      } else {
        // print(
        //     "[Streak Reminder] Last streak activity was on $lastActivityTime. Checking for reminder.");

        final sevenDaysAgo = now.subtract(const Duration(days: 7));
        recentDates =
            streak.dates.where((date) => date.isAfter(sevenDaysAgo)).toList();
        // print(
        //     "[Streak Reminder] Found ${recentDates.length} activities in the last 7 days.");
      }
    } else {
      // print(
      //     "[Streak Reminder] No streak data or no dates found for user $userId. Scheduling reminder for default time.");
      // Keep needsReminder = true
    }

    if (needsReminder) {
      DateTime scheduledDateTime;
      TimeOfDay? averageTime = _calculateAverageTime(recentDates);

      if (averageTime != null) {
        // Useing average time from last 7 days
        // print("[Streak Reminder] Calculated average activity time: ${averageTime.format(context)}");
        final tomorrow = now.add(const Duration(days: 1));
        scheduledDateTime = DateTime(tomorrow.year, tomorrow.month,
            tomorrow.day, averageTime.hour, averageTime.minute);
        // print("[Streak Reminder] Scheduling based on average time for: $scheduledDateTime");

        // If the calculated average time for tomorrow is in the past, schedule for the day after tomorrow
        if (scheduledDateTime.isBefore(now)) {
          // print("[Streak Reminder] Average time for tomorrow is in the past. Adjusting to day after tomorrow.");
          // scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
          scheduledDateTime = scheduledDateTime.add(const Duration(seconds: 1));
        }
      } else {
        // Fallback logic (no recent dates or no streak data)
        // print(
        //     "[Streak Reminder] No recent activity or no streak data. Using fallback scheduling.");
        if (lastActivityTime != null) {
          // Schedule 24 hours after the last known activity time
          scheduledDateTime = lastActivityTime.add(const Duration(days: 1));
          // print(
          //     "[Streak Reminder Fallback] Calculated schedule time (24h after last activity): $scheduledDateTime");

          // If the calculated time is in the past, schedule it for 1 minute from now
          if (scheduledDateTime.isBefore(now)) {
            // print(
            //     "[Streak Reminder Fallback] Calculated schedule time is in the past. Scheduling for 1 minute from now.");
            scheduledDateTime = now.add(const Duration(minutes: 1));
          }
        } else {
          // Absolute Fallback: No streak data at all, schedule for 9 AM tomorrow
          final tomorrow = now.add(const Duration(days: 1));
          scheduledDateTime =
              DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0, 0);
          // print(
          //     "[Streak Reminder Fallback] No last activity time found. Scheduling reminder for default time: $scheduledDateTime");
          // Ensure default time is in the future (edge case)
          if (scheduledDateTime.isBefore(now)) {
            scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
            // print(
            // "[Streak Reminder Fallback] Default 9 AM tomorrow was in the past. Adjusting to day after tomorrow: $scheduledDateTime");
          }
        }
      }

      print(
          "[Streak Reminder] Final Scheduling time for reminder ID $reminderId: $scheduledDateTime");
      await _notificationService.scheduleLocalNotification(
        id: reminderId,
        title: 'Keep your streak going! 🔥',
        body: 'Complete a lesson today to maintain your learning streak.',
        scheduledDateTime: scheduledDateTime,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        backgroundColor: Color(0xFFFFFFFF),
        destinations: const [
          NavigationDestination(
              selectedIcon: Icon(
                LucideIcons.home,
              ),
              icon: Icon(LucideIcons.home, color: Colors.amber),
              label: 'Home'),
          NavigationDestination(
              selectedIcon: Icon(LucideIcons.dumbbell),
              icon: Icon(
                LucideIcons.dumbbell,
                color: Colors.blue,
              ),
              label: 'Training'),
          NavigationDestination(
              selectedIcon: Icon(LucideIcons.joystick),
              icon: Icon(LucideIcons.joystick, color: Colors.purpleAccent),
              label: 'Blockly'),
          NavigationDestination(
              selectedIcon: Icon(LucideIcons.award),
              icon: Icon(LucideIcons.award, color: Colors.green),
              label: 'Leaderboard'),
          NavigationDestination(
              selectedIcon: Icon(LucideIcons.user),
              icon: Icon(LucideIcons.user, color: Colors.redAccent),
              label: 'Profile'),
        ],
      ),
      body: <Widget>[
        LessonMain(),
        Training(),
        kIsWeb
            ? WebViewApp()
            : const Center(
                child: Text(
                  'Blockly editor is not available on the Mobile version',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
        LeaderboardPage(),
        Profile(),
      ][currentPageIndex],
    );
  }
}
