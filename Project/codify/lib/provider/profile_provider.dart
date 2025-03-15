import 'package:codify/services/auth.dart';
import 'package:flutter/material.dart';
import '../user/user_service.dart';
import '../user/user.dart';

class ProfileProvider with ChangeNotifier {
  final AuthService _authService=AuthService();
  final UserService _userService = UserService();
  UserDetail? _userDetail;


  UserDetail? get userDetail => _userDetail;

ProfileProvider(){
  fetchUserById();
}


  Future<void> fetchUserById() async {
    try {
      final userId=await _authService.getUID();
      List<UserDetail> users = await _userService.getUserByUserId(userId!);
      if (users.isNotEmpty) {
        _userDetail = users.first;
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

  Future<void> setHasRedirected() async {
    try {
      final userId = await _authService.getUID();
      if (userId != null) {
        await _userService.setHasRedirected(userId);
        _userDetail?.hasBeenRedirected = true;
        notifyListeners();
      }
    } catch (e) {
      print("Error setting hasRedirected: $e");
    }
  }


  void reset() {
    _userDetail = null;
    notifyListeners();
  }
}