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
  bool isUploading = false;
  bool graphDataLoaded = false;
  List<ImageModel> images = [];
  UserDetail? user;
  Map<String, int> userDailyPoints = {};
  bool _initialized = false;
  Timer? _graphRefreshTimer;
  StreamSubscription? _pointsUpdatesSubscription;

  bool get initialized => _initialized;

  StreamSubscription? _userStreamSubscription;

  ProfileProvider() {
    _graphRefreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (!isLoading && _initialized) {
        _refreshGraphData();
      }
    });
  }

 
  void checkUserBlacklisted(BuildContext context) {
    if (user != null && user!.isBlacklisted) {
      String message = 'Your account has been blacklisted.';
      if (user!.blacklistReason != null && user!.blacklistReason!.isNotEmpty) {
        message += '\n\nReason: ${user!.blacklistReason}';
      }


      showDialog(
        context: context,
        barrierDismissible: false, 
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFFFFFFFF),
            title: const Text('Account Restricted',
                style: TextStyle(color: Colors.red)),
            content: Text(message, style: const TextStyle(color: Colors.blue)),
            actions: <Widget>[
              TextButton(
                child: const Text('OK', style: TextStyle(color: Colors.green)),
                onPressed: () {
                  Navigator.of(context).pop();
                  
                  signOut(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _refreshGraphData() async {
    graphDataLoaded = false;
    notifyListeners();

    try {
      await _fetchUserPoints();
    } catch (e) {
      print('Error refreshing graph data: $e');
    }

    notifyListeners();
  }

  Future<void> fetchData() async {
    print(
        "ProfileProvider: fetchData called, isLoading=$isLoading, initialized=$_initialized, user=${user != null ? 'available' : 'null'}");
    if (isLoading || (_initialized && !images.isEmpty && user != null)) {
      print(
          "ProfileProvider: Skipping fetchData due to already loading or initialized state");
      return;
    }
    _initialized = true;
    isLoading = true;
    graphDataLoaded = false;
    notifyListeners();
    print("ProfileProvider: Starting data fetching process");
    try {
      await _fetchUserImage();
      print("ProfileProvider: User images fetched: ${images.length}");

      await _fetchUserData();
      print("ProfileProvider: User data fetch initiated");

      await _fetchUserPoints();
      print("ProfileProvider: User points fetched");
    } catch (e) {
      print("ProfileProvider ERROR: ${e.toString()}");
    }
    isLoading = false;
    notifyListeners();
    print("ProfileProvider: Data loading completed, isLoading set to false");
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

          
          if (user != null && user!.isBlacklisted) {
            print(
                "ProfileProvider: User is blacklisted: ${user!.blacklistReason}");
          }
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

  
  void refreshAfterPointsUpdate() {
    _refreshGraphData();
  }

  
  Future<void> refreshProfile() async {
    if (isLoading) return;

    graphDataLoaded = false;
    notifyListeners();

    try {
      await _fetchUserPoints();
    } catch (e) {
      print('Error refreshing profile data: $e');
    }

    notifyListeners();
  }


  bool _isPickerActive = false;

  Future<void> pickAndUploadImage(BuildContext context) async {
    
    if (_isPickerActive || isUploading) {
      print('Image picker or upload already in progress');
      return;
    }

    try {
      _isPickerActive = true;
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      _isPickerActive = false;

      if (picked == null) return;

      isUploading = true;
      notifyListeners();

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

      if (cropped == null) {
        isUploading = false;
        notifyListeners();
        return;
      }

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
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image. Please try again.')),
      );
    } finally {
      isUploading = false;
      notifyListeners();
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
    
    _cancelAllSubscriptions();

   
    _initialized = false;
    isLoading = false;
    graphDataLoaded = false;
    images.clear();
    user = null;
    userDailyPoints.clear();
    notifyListeners();

    
    await _auth.signOut(context);
  }

  
  void _cancelAllSubscriptions() {
    if (_userStreamSubscription != null) {
      _userStreamSubscription!.cancel();
      _userStreamSubscription = null;
      print("ProfileProvider: Cancelled user stream subscription");
    }

    if (_graphRefreshTimer != null) {
      _graphRefreshTimer!.cancel();
      _graphRefreshTimer = null;
      print("ProfileProvider: Cancelled graph refresh timer");
    }

    if (_pointsUpdatesSubscription != null) {
      _pointsUpdatesSubscription!.cancel();
      _pointsUpdatesSubscription = null;
      print("ProfileProvider: Cancelled points updates subscription");
    }
  }

  @override
  void dispose() {
    _cancelAllSubscriptions();
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
