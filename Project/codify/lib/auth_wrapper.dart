import 'package:codify/pages/loader.dart';
import 'package:codify/pages/redirect_add_lesson.dart';
import 'package:codify/provider/lesson_provider.dart';
import 'package:codify/provider/profile_provider.dart';
import 'package:codify/user/redirect_add_profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:codify/pages/home.dart';
import 'package:codify/pages/login.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final lessonProvider = context.watch<LessonProvider>();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.active) {
          return const LoadingScreen();
        }

        final user = snapshot.data;

        if (user == null) {
          return const Login();
        }

        final isProfileMissing = profileProvider.userDetail?.age == null ||
            profileProvider.userDetail?.name == null;

        if (isProfileMissing) {
          if (profileProvider.isLoading) {
            return const LoadingScreen();
          } else {
            return const RedirectProfile();
          }
        }

        final hasNoLessons = lessonProvider.userLessons.isEmpty;

        if (hasNoLessons) {
          return const RedirectAddCourse();
        }

        return const Home();
      },
    );
  }
}
