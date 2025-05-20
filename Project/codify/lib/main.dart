import 'package:codify/pages/badge_provider.dart';
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
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'dart:io'
    if (dart.library.html) 'package:codify/web_stub/platform_stub.dart'
    as platform;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kIsWeb) {
    if (kDebugMode) {
      print("Running on web platform - initializing web configuration");
      print("NotificationService initialization skipped on web.");
    }

    tz.initializeTimeZones();
  } else {
    try {
      if (platform.Platform.isAndroid) {}

      final notificationService = NotificationService();
      await notificationService.initialize();

      tz.initializeTimeZones();
    } catch (e) {
      if (kDebugMode) {
        print("Error during platform initialization: $e");
      }
    }
  }

  runApp(const MyApp());

  Future.delayed(const Duration(seconds: 1), () {
    FlutterNativeSplash.remove();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Phoenix(
      child: MultiProvider(
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
          ChangeNotifierProvider(create: (context) => BadgeProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}
