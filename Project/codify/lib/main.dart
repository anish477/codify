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


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiProvider(providers: [

      ChangeNotifierProvider(create: (context)=> LessonProvider(),
      ),
      ChangeNotifierProvider(create: (context)=>LivesProvider()),
      ChangeNotifierProvider(create: (context)=>StreakProvider()),
      ChangeNotifierProvider(create: (context)=>ProfileProvider(),),
      ChangeNotifierProvider(create: (context)=>LeaderboardProvider()),
      ChangeNotifierProvider(create: (context)=>UserStatProvider()),
      ChangeNotifierProvider(create: (context)=>ProfileProvider())


    ],
    child:MaterialApp(
        home: const AuthWrapper(),

    ),
    );


  }
}