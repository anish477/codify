import 'package:flutter/material.dart';
import 'package:codify/pages/splash.dart';
import 'package:codify/pages/home.dart';
import 'package:codify/pages/login.dart';
import 'package:codify/pages/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(MaterialApp(
    routes: {
      '/': (context) => const Splash(),
      '/login': (context) => const Login(),
      '/signup': (context) => const Signup(),
      '/home': (context) => const Home(),
    },
  ));
}

