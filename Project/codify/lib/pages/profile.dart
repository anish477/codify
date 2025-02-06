import 'package:codify/user/user.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:codify/services/upload_image.dart';
import 'package:codify/pages/setting.dart';
import 'package:codify/user/user_service.dart';
import 'package:codify/services/auth.dart';
import '../user/image.dart';
import '../user/image_service.dart';
import 'package:shimmer/shimmer.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ImagePicker _picker = ImagePicker();
  final UserService _userService = UserService();
  final UploadImageService _uploadImageService = UploadImageService();
  final AuthService _auth = AuthService();
  final ImageService _imageService = ImageService();

  bool _isUploading = false;
  bool _isLoading = false;
  String? _imageUrl;
  List<ImageModel> images = [];

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _isUploading = true;
      });
      final imageUrl = await _uploadImageService.uploadImage(context, image);

      if (imageUrl != null) {
        if (!mounted) return;
        await _addImage(imageUrl);
        await _fetchData(); // Refresh all data after adding image
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to Upload Image.")));
        setState(() {
          _isUploading = false;
        });
      }
    } else {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _fetchData() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      await _fetchUserImage();
    } catch (e) {
      print("Error fetching user data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to fetch user data. Please try again later.')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchUserImage() async {
    final String? userId = await _auth.getUID();
    if (userId != null) {
      final fetchedImage = await _imageService.getImageByUserId(userId);
      if (mounted) {
        setState(() {
          images = fetchedImage;
          _isLoading = false;
        });
      }
    }
    print("Fetched images: $images");
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Setting()),
              );
              // if (result == true) {
              //   _fetchData();
              // }
            },
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.settings),
            ),
          ),
        ],
      ),
      body: FutureBuilder<String?>(
        future: _auth.getUID(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No user ID available'));
          } else {
            final userId = snapshot.data!;
            return StreamBuilder<List<UserDetail>>(
              stream: _userService.getUserStreamByUserId(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    enabled: true,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const CircleAvatar(radius: 60.0, backgroundColor: Colors.grey),
                          const SizedBox(height: 10),
                          Container(height: 20, width: 100, color: Colors.white),
                          const SizedBox(height: 10),
                          Container(height: 20, width: 80, color: Colors.white),
                          const SizedBox(height: 20),
                          Container(
                            height: 50,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No user information available'));
                } else {
                  final user = snapshot.data!.first;
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          _buildAvatar(),
                          const SizedBox(height: 20),
                          _buildUserInfo(user),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _pickAndUploadImage,
                            child: const Text("Change Avatar"),
                          ),

                        ],
                      ),
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _addImage(String imageUrl) async {
    final String? userId = await _auth.getUID();

    final imageData = ImageModel(
      documentId: "",
      image: imageUrl,
      userId: userId,
    );

    await _imageService.addImage(imageData);
  }

  Widget _buildAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 60.0,
          backgroundColor: Colors.grey,
          child: ClipOval(
            child: Image.network(
              images.isNotEmpty ? images.first.image : "https://cdn-icons-png.flaticon.com/512/3177/3177283.png",
              fit: BoxFit.cover,
              width: 120.0,
              height: 120.0,
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 120.0,
                    height: 120.0,
                    color: Colors.white,
                  ),
                );
              },
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                return Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 120.0,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(UserDetail user) {
    return Column(
      children: [
        Text(
          user.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          "Age: ${user.age}",
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}