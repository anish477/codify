import 'package:codify/pages/add_course.dart';
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
    final profileProvider = Provider.of<ProfileProvider>(context);
    final lessonProvider=Provider.of<LessonProvider>(context);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          // print('User: $user');
          print('User age: ${profileProvider.userDetail?.age}');
          if (user == null) {
            return const Login();
          }
          // else if (profileProvider.userDetail?.age == null ||profileProvider.userDetail?.name==null) {
          //   return const RedirectProfile();
          // }
          //
          // else if(lessonProvider.userLessons.isEmpty){
          //   return const AddCourse();
          // }



          else {
            return const Home();
          }
        } else {
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