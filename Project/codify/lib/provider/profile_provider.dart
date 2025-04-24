// ProfileProvider
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
    if (!isLoading) {
      isLoading = true;
      errorMessage = null;
    }

    final uid = await _authService.getUID();
    if (uid != null) {
      try {
        final users = await _userService.getUserByUserId(uid);
        if (users.isNotEmpty) {
          userDetail = users.first;
          errorMessage = null;
        } else {
          userDetail = null;
          errorMessage = "No user details found for UID: $uid";
          print(errorMessage);
        }
      } catch (e) {
        userDetail = null;
        errorMessage = 'Error fetching user details: $e';
        print(errorMessage);
      }
    } else {
      userDetail = null;
      errorMessage = "User not logged in.";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> markProfileComplete() async {
    if (userDetail != null) {
      final updatedUser = UserDetail(
        documentId: userDetail!.documentId,
        name: userDetail!.name,
        age: userDetail!.age,
        userId: userDetail!.userId,
        fcmToken: userDetail!.fcmToken,
        profileComplete: true,
      );
      try {
        await _userService.updateUser(updatedUser);
        userDetail = updatedUser;
        notifyListeners();
      } catch (e) {
        errorMessage = 'Error marking profile as complete: $e';
        print(errorMessage);
      }
    } else {
      errorMessage = "User detail is null, cannot mark profile as complete";
      print(errorMessage);
    }
  }

  void reset() {
    userDetail = null;
    fetchUserDetails();
  }

  // Future<void> refreshFcmToken() async {
  //   if (userDetail != null) {
  //     // final notificationService = NotificationService();
  //     // await notificationService.refreshToken();
  //   }
  // }
}
