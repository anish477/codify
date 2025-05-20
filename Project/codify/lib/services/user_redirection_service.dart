import 'package:flutter/material.dart';
import '../user/user_lesson_service.dart';
import '../services/auth.dart';
import '../pages/add_course.dart';
import '../pages/redirect_add_lesson.dart';
import '../pages/home.dart';

class UserRedirectionService {
  final UserLessonService _userLessonService = UserLessonService();
  final AuthService _auth = AuthService();

  Future<bool> checkAndRedirect(BuildContext context, String? username) async {
    if (username == null || username.isEmpty) {
      return false;
    }

    final String? userId = await _auth.getUID();
    if (userId == null) {
      return false;
    }

    final userLessons = await _userLessonService.getUserLessonByUserId(userId);

    if (userLessons != null && userLessons.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
      return true;
    }

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RedirectAddCourse()),
    );

    return true;
  }
}
