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
import '../gamification/blockly.dart';
import '../services/user_redirection_service.dart';
import 'package:provider/provider.dart';
import '../provider/profile_provider.dart';
import '../user/redirect_add_profile.dart';
import '../user/user_service.dart';
import '../user/user_lesson_service.dart';
import 'redirect_add_lesson.dart';

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
  final UserRedirectionService _redirectionService = UserRedirectionService();
  final UserLessonService _userLessonService = UserLessonService();
  int currentPageIndex = 0;

  static bool _redirectionChecked = false;
  static bool _isPerformingRedirection = false;

  @override
  void initState() {
    super.initState();
    _scheduleStreakReminder();

    if (!_redirectionChecked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkRedirections();
      });
    }
  }

  Future<void> _checkRedirections() async {
    if (_isPerformingRedirection) {
      return;
    }
    _isPerformingRedirection = true;

    try {
      final String? userId = await _auth.getUID();
      if (userId != null) {
        final UserService _userService = UserService();
        final users = await _userService.getUserByUserId(userId);

        await _userLessonService.getUserLessonByUserId(userId);

        if (users.isEmpty) {
          if (mounted) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => RedirectProfile()));
          }
          return;
        }

        final userLessons =
            await _userLessonService.getUserLessonByUserId(userId);
        if (userLessons.isEmpty && mounted) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const RedirectAddCourse()));
          return;
        }

        final profileProvider =
            Provider.of<ProfileProvider>(context, listen: false);

        if (profileProvider.user != null) {
          profileProvider.checkUserBlacklisted(context);

          if (profileProvider.user != null &&
              !profileProvider.user!.isBlacklisted) {
            final username = profileProvider.user!.name;
            await _redirectionService.checkAndRedirect(context, username);
          }
        } else {
          profileProvider.fetchData();

          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              profileProvider.checkUserBlacklisted(context);
            }
          });
        }

        _redirectionChecked = true;
      }
    } finally {
      _isPerformingRedirection = false;
    }
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
      } else {
        final sevenDaysAgo = now.subtract(const Duration(days: 7));
        recentDates =
            streak.dates.where((date) => date.isAfter(sevenDaysAgo)).toList();
      }
    } else {}

    if (needsReminder) {
      DateTime scheduledDateTime;
      TimeOfDay? averageTime = _calculateAverageTime(recentDates);

      if (averageTime != null) {
        final tomorrow = now.add(const Duration(days: 1));
        scheduledDateTime = DateTime(tomorrow.year, tomorrow.month,
            tomorrow.day, averageTime.hour, averageTime.minute);

        if (scheduledDateTime.isBefore(now)) {
          scheduledDateTime = scheduledDateTime.add(const Duration(seconds: 1));
        }
      } else {
        if (lastActivityTime != null) {
          scheduledDateTime = lastActivityTime.add(const Duration(days: 1));

          if (scheduledDateTime.isBefore(now)) {
            scheduledDateTime = now.add(const Duration(minutes: 1));
          }
        } else {
          final tomorrow = now.add(const Duration(days: 1));
          scheduledDateTime =
              DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0, 0);

          if (scheduledDateTime.isBefore(now)) {
            scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
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
      backgroundColor: const Color(0xFFFFFFFF),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        backgroundColor: const Color(0xFFFFFFFF),
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
        const LessonMain(),
        const Training(),
        WebViewApp(),
        const LeaderboardPage(),
        const Profile(),
      ][currentPageIndex],
    );
  }
}
