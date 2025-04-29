import 'package:flutter/material.dart';
import 'package:codify/services/auth.dart';
import 'package:codify/user/user_service.dart';
import 'package:codify/user/user.dart';

class AddProfileProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();
  final UserService _userService = UserService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  bool isLoading = true;
  bool isEditing = false;
  bool isSaving = false;

  void fetchUserData() async {
    isLoading = true;
    notifyListeners();
    final String? userId = await _auth.getUID();
    if (userId != null) {
      final fetched = await _userService.getUserByUserId(userId);
      if (fetched.isNotEmpty) {
        final u = fetched.first;
        nameController.text = u.name;
        ageController.text = u.age.toString();
        isEditing = true;
      }
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> saveProfile(BuildContext context) async {
    isSaving = true;
    notifyListeners();
    final String? userId = await _auth.getUID();
    if (userId == null) {
      isSaving = false;
      notifyListeners();
      return false;
    }
    final user = UserDetail(
      documentId: isEditing ? '' : '',
      name: nameController.text,
      age: int.tryParse(ageController.text) ?? 0,
      userId: userId,
      fcmToken: '',
    );
    try {
      if (isEditing) {
        await _userService.updateUser(user);
      } else {
        await _userService.addUser(user);
      }
      return true;
    } catch (e) {
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }
}
