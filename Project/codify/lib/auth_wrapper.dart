import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:codify/pages/home.dart';
import 'package:codify/pages/login.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            // User is not logged in
            return const Login();
          } else {
            // User is logged in
            return const Home();
          }
        } else {
          // Waiting for authentication state
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}