import 'package:codify/pages/redirect_add_lesson.dart';
import 'package:codify/user/user.dart';
import 'package:flutter/material.dart';
import 'package:codify/user/user_service.dart';
import 'package:codify/services/auth.dart';
import 'package:shimmer/shimmer.dart';
import 'package:codify/provider/profile_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:codify/services/user_redirection_service.dart';

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
  final UserRedirectionService _redirectionService = UserRedirectionService();
  List<UserDetail> _userDetails = [];
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _hasImage = false;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).fetchData();
    });
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
                  Consumer<ProfileProvider>(
                    builder: (context, profileProvider, _) {
                      _hasImage = profileProvider.images.isNotEmpty;
                      return Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                profileProvider.pickAndUploadImage(context);
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[200],
                                      image: profileProvider.images.isNotEmpty
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                  profileProvider
                                                      .images.first.image),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: profileProvider.isUploading
                                        ? Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          )
                                        : profileProvider.images.isEmpty
                                            ? Icon(
                                                Icons.person,
                                                size: 50,
                                                color: Colors.grey[400],
                                              )
                                            : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            if (!_hasImage)
                              Text(
                                "Profile image is required",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24),
                  TextFormField(
                    controller: _nameTextController,
                    decoration: const InputDecoration(
                      labelText: "Name *",
                      hintText: "Enter your full name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ageTextController,
                    decoration: const InputDecoration(
                      labelText: "Age *",
                      hintText: "Enter your age",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your age';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      int? age = int.tryParse(value);
                      if (age != null) {
                        if (age <= 0) {
                          return 'Age must be greater than 0';
                        }
                        if (age > 120) {
                          return 'Please enter a valid age';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      bool isValid = _formKey.currentState!.validate();
                      bool hasProfileImage =
                          Provider.of<ProfileProvider>(context, listen: false)
                              .images
                              .isNotEmpty;

                      if (!hasProfileImage) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please upload a profile image'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (isValid) {
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

      final hasImage = Provider.of<ProfileProvider>(context, listen: false)
          .images
          .isNotEmpty;
      final hasName = _nameTextController.text.trim().isNotEmpty;
      final hasAge = _ageTextController.text.trim().isNotEmpty;

      if (hasImage && hasName && hasAge) {
        if (mounted) {
          final profileProvider =
              Provider.of<ProfileProvider>(context, listen: false);
          await profileProvider.fetchData();

          if (profileProvider.user != null) {
            await _redirectionService.checkAndRedirect(
                context, profileProvider.user!.name);
          } else {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const RedirectAddCourse()));
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please complete all required fields')),
          );
        }
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
