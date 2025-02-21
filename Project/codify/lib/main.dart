import 'package:codify/provider/lesson_provider.dart';
import 'package:codify/provider/lives_provider.dart';
import 'package:codify/provider/streak_provider.dart';
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

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {

    return MultiProvider(providers: [

      ChangeNotifierProvider(create: (context)=> LessonProvider(),
      ),
      ChangeNotifierProvider(create: (context)=>LivesProvider()),
      ChangeNotifierProvider(create: (context)=>StreakProvider()),


    ],
    child:MaterialApp(
        home: const AuthWrapper(),

    ),
    );


  }
}