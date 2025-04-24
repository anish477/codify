import 'package:codify/provider/leaderboard_provider.dart';
import 'package:codify/provider/lesson_provider.dart';
import 'package:codify/provider/lives_provider.dart';
import 'package:codify/provider/profile_provider.dart';
import 'package:codify/provider/streak_provider.dart';
import 'package:codify/provider/user_stat_provider.dart';
import 'package:codify/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:codify/auth_wrapper.dart';
import "package:provider/provider.dart";
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    final notificationService = NotificationService();
    await notificationService.initialize();
  } else {
    print("NotificationService initialization skipped on web.");
  }

  tz.initializeTimeZones();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LessonProvider(),
        ),
        ChangeNotifierProvider(create: (context) => LivesProvider()),
        ChangeNotifierProvider(create: (context) => StreakProvider()),
        ChangeNotifierProvider(
          create: (context) => ProfileProvider(),
        ),
        ChangeNotifierProvider(create: (context) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (context) => UserStatProvider()),
      ],
      child: MaterialApp(
        home: const AuthWrapper(),
      ),
    );
  }
}
