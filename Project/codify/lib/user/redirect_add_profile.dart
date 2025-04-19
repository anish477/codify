import 'package:codify/pages/redirect_add_lesson.dart';
import 'package:codify/user/user.dart';
import 'package:flutter/material.dart';
import 'package:codify/user/user_service.dart';
import 'package:codify/services/auth.dart';
import 'package:shimmer/shimmer.dart';

class RedirectProfile extends StatefulWidget {
  const RedirectProfile({super.key});
  @override
  State<RedirectProfile> createState() => _ProfileState();
}

class _ProfileState extends State<RedirectProfile> {
  final _formKey = GlobalKey<FormState>();
  final _nameTextController = TextEditingController();
  final _ageTextController = TextEditingController();
  final AuthService _auth = AuthService();
  final UserService _userService = UserService();
  List<UserDetail> _userDetails = [];
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameTextController.dispose();
    _ageTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        title: Text(
          _isEditing ? "Edit Profile" : "Add Profile",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  _isLoading
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: 56,
                            width: double.infinity,
                            color: Colors.white,
                          ),
                        )
                      : TextFormField(
                          controller: _nameTextController,
                          decoration: const InputDecoration(
                            labelText: "Name",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ageTextController,
                    decoration: const InputDecoration(
                      labelText: "Age",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your age';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Please enter a valid age';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _saveProfile();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
    });

    final String? userId = await _auth.getUID();
    if (userId == null) {
      setState(() {
        _isSaving = false;
      });
      return;
    }

    final user = UserDetail(
      documentId: _isEditing ? _userDetails.first.documentId : "",
      name: _nameTextController.text,
      age: int.parse(_ageTextController.text),
      userId: userId,
      fcmToken: '',
    );

    try {
      if (_isEditing) {
        await _userService.updateUser(user);
      } else {
        await _userService.addUser(user);
      }

      if (mounted) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => RedirectAddCourse()));
      }
    } catch (e) {
      print("Error saving user data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save user data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String? userId = await _auth.getUID();
      if (userId != null) {
        final fetchedUsers = await _userService.getUserByUserId(userId);
        if (mounted) {
          setState(() {
            _userDetails = fetchedUsers;
            if (_userDetails.isNotEmpty) {
              _nameTextController.text = _userDetails.first.name;
              _ageTextController.text = _userDetails.first.age.toString();
              _isEditing = true;
            } else {
              _isEditing = false;
            }
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Failed to fetch user data. Please try again later.'),
            action: SnackBarAction(
              label: "Retry",
              onPressed: _fetchUserData,
            ),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
