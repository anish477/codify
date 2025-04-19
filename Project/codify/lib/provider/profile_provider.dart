import 'package:flutter/material.dart';

import '../services/auth.dart';
import '../user/user_service.dart';
import '../user/user.dart';

class ProfileProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  UserDetail? userDetail;
  bool isLoading = true;
  String? errorMessage;

  ProfileProvider() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    await fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final uid = await _authService.getUID();
    if (uid != null) {
      try {
        final users = await _userService.getUserByUserId(uid);
        if (users.isNotEmpty) {
          userDetail = users.first;
        } else {
          errorMessage = "Invalid or empty user data received.";
        }
      } catch (e) {
        errorMessage = 'Error fetching user details: $e';
        print(errorMessage);
      }
    } else {
      errorMessage = "User not logged in.";
    }

    isLoading = false;
    notifyListeners();
  }

  void reset() {
    userDetail = null;
    fetchUserDetails();
  }

  // Add this method to your ProfileProvider class
  Future<void> refreshFcmToken() async {
    if (userDetail != null) {
      // final notificationService = NotificationService();
      // await notificationService.refreshToken();
    }
  }
}
