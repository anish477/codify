import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:codify/services/upload_image.dart';
import 'package:codify/user/image.dart';
import 'package:codify/user/image_service.dart';
import 'package:codify/user/user.dart';
import 'package:codify/user/user_service.dart';
import 'package:codify/services/auth.dart';
import 'package:codify/gamification/leaderboard_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final UploadImageService _uploadImageService = UploadImageService();
  final UserService _userService = UserService();
  final AuthService _auth = AuthService();
  final ImageService _imageService = ImageService();
  final LeaderboardService _leaderboardService = LeaderboardService();

  bool isLoading = false;
  bool graphDataLoaded = false;
  List<ImageModel> images = [];
  UserDetail? user;
  Map<String, int> userDailyPoints = {};
  bool _initialized = false;

  bool get initialized => _initialized;

  StreamSubscription? _userStreamSubscription;

  ProfileProvider() {
    fetchData();
  }

  Future<void> fetchData() async {
    if (_initialized) return;
    _initialized = true;
    isLoading = true;
    graphDataLoaded = false;
    notifyListeners();
    try {
      await _fetchUserImage();
      await _fetchUserData();
      await _fetchUserPoints();
    } catch (e) {
      print('Error fetching profile data: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchUserImage() async {
    final userId = await _auth.getUID();
    if (userId != null) {
      images = await _imageService.getImageByUserId(userId);
      notifyListeners();
    }
  }

  Future<void> _fetchUserData() async {
    final userId = await _auth.getUID();
    if (userId != null) {
      _userStreamSubscription?.cancel();
      _userStreamSubscription =
          _userService.getUserStreamByUserId(userId).listen((users) {
        if (users.isNotEmpty) {
          user = users.first;
          notifyListeners();
        }
      });
    }
  }

  Future<void> _fetchUserPoints() async {
    final userId = await _auth.getUID();
    if (userId != null) {
      userDailyPoints = await _leaderboardService.getUserPointsByDay(userId);
    }
    graphDataLoaded = true;
    notifyListeners();
  }

  Future<void> pickAndUploadImage(BuildContext context) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: <PlatformUiSettings>[
        AndroidUiSettings(
          toolbarColor: Colors.blue,
          backgroundColor: Colors.black,
          dimmedLayerColor: Colors.black54,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
        ),
      ],
    );
    if (cropped == null) return;
    final imageUrl =
        await _uploadImageService.uploadImage(context, XFile(cropped.path));
    if (imageUrl != null) {
      if (images.isNotEmpty) {
        await _updateImage(images.first.documentId, imageUrl);
      } else {
        await _addImage(imageUrl);
      }
      await _fetchUserImage();
    }
  }

  Future<void> _updateImage(String userId, String newUrl) async {
    await _imageService.updateImage(userId, {'image': newUrl});
  }

  Future<void> _addImage(String url) async {
    final userId = await _auth.getUID();
    final img = ImageModel(documentId: '', image: url, userId: userId);
    await _imageService.addImage(img);
  }

  List<ChartData>? get chartData {
    final List<ChartData> data = [];
    if (userDailyPoints.isNotEmpty) {
      userDailyPoints.forEach((date, pts) {
        try {
          data.add(ChartData(DateTime.parse(date), pts));
        } catch (_) {}
      });
      data.sort((a, b) => a.date.compareTo(b.date));
    } else {
      final now = DateTime.now();
      for (var i = 6; i >= 0; i--) {
        data.add(ChartData(now.subtract(Duration(days: i)), 0));
      }
    }
    return data;
  }

  Future<void> signOut(BuildContext context) async {
    await _auth.signOut(context);
  }

  @override
  void dispose() {
    _userStreamSubscription?.cancel();
    super.dispose();
  }

  void reset() {
    _initialized = false;
    isLoading = false;
    graphDataLoaded = false;
    images.clear();
    user = null;
    userDailyPoints.clear();
    notifyListeners();
    fetchData();
  }
}

class ChartData {
  ChartData(this.date, this.points);
  final DateTime date;
  final int points;
}
