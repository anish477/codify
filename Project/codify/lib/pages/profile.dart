import 'dart:async';

import 'package:codify/provider/streak_provider.dart';
import 'package:codify/user/user.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:codify/services/upload_image.dart';
import 'package:codify/pages/setting.dart';
import 'package:codify/user/user_service.dart';
import 'package:codify/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../provider/leaderboard_provider.dart';
import '../user/image.dart';
import '../user/image_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:codify/gamification/leaderboard_service.dart';
import 'package:intl/intl.dart';

import '../widget/fullScreenImage.dart';

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
  final LeaderboardService _leaderboardService = LeaderboardService();

  bool _isUploading = false;
  bool _isLoading = false;
  List<ImageModel> images = [];
  UserDetail? _user;
  Map<String, int> _userPointsForGraph = {};
  bool _graphDataLoaded = false;


  StreamSubscription? _userStreamSubscription;

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _isUploading = true;
      });
      final imageUrl = await _uploadImageService.uploadImage(context, image);

      if (imageUrl != null) {
        if (!mounted) return;
        if (images.isNotEmpty) {
          await _updateImage(images.first.documentId, imageUrl);
        } else {
          await _addImage(imageUrl);
        }
        await _fetchData();
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
      _graphDataLoaded = false; // Reset the flag
    });

    try {
      await _fetchUserImage();
      await _fetchUserData();
      await _fetchUserPoints(); // Fetch points first
    } catch (e) {
      print("Error fetching user data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Failed to fetch user data. Please try again later.')));
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
        });
      }
    }
    print("Fetched images: $images");
  }

  Future<void> _fetchUserData() async {
    final String? userId = await _auth.getUID();
    if (userId != null) {
      // Cancel any previous subscription:
      _userStreamSubscription?.cancel();

      // Subscribe to the stream and store the subscription:
      _userStreamSubscription = _userService.getUserStreamByUserId(userId).listen((users) {
        if (users.isNotEmpty && mounted) {
          setState(() {
            _user = users.first;
          });
        }
      });
    }
  }

  Future<void> _fetchUserPoints() async {
    await Provider.of<LeaderboardProvider>(context, listen: false).getTotalPointsByUserPerDayLast7Days();

    setState(() {
      _graphDataLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    // Cancel the stream subscription in dispose:
    _userStreamSubscription?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Color(0xFFFFFFFF),
        shadowColor: Colors.black.withOpacity(0.5),
        actions: [
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Setting()),
              );
              _fetchData();
            },
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.settings),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: const CircularProgressIndicator())
          : _user != null
          ? _buildProfileContent(context)
          : const Center(child: Text('No user data available')),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    final streak = Provider.of<StreakProvider>(context).streak;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildAvatar(),
              const SizedBox(height: 20),
              _buildUserInfo(_user!),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              Text("${streak?.currentStreak} Days", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              _buildTrendGraph(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateImage(String documentId, String newImageUrl) async {
    try {
      await _imageService.updateImage(documentId, {'image': newImageUrl});
      await _fetchUserImage();
    } catch (e) {
      print("Error updating image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to update image.")));
      }
    }
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
    String imageUrl = images.isNotEmpty
        ? images.first.image
        : "https://cdn-icons-png.flaticon.com/512/3177/3177283.png";
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenImage(imageUrl: imageUrl),
              ),
            );
          },
          child: Hero(
            tag: 'profileImage',
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.amber,
              child: ClipOval(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  height: 120,
                  width: 120,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
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
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return const Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 120.0,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: -7,
          right: 0,
          child: IconButton(
            onPressed: _pickAndUploadImage,
            icon: Icon(Icons.edit, color: Colors.blue, size: 30),
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

  Widget _buildTrendGraph() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: _graphDataLoaded ? SfCartesianChart(
        title: ChartTitle(text: 'XP Trend'),
        primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat.MMMd(),
          intervalType: DateTimeIntervalType.days,
          interval: 1,
          majorGridLines: const MajorGridLines(width: 0),
          axisLine: const AxisLine(width: 0),
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: 'XP'),
          axisLine: const AxisLine(width: 0),
          majorGridLines: const MajorGridLines(width: 1),
        ),
        series: <CartesianSeries>[
          LineSeries<ChartData, DateTime>(
            dataSource: _prepareChartData(),
            xValueMapper: (ChartData data, _) => data.date,
            yValueMapper: (ChartData data, _) => data.points,
            color: Colors.blueAccent,
            width: 3,
            markerSettings: const MarkerSettings(
              isVisible: true,
              height: 8,
              width: 8,
              color: Colors.blue,
            ),
          )
        ],
        plotAreaBorderWidth: 0,
      ) : Center(child: CircularProgressIndicator()),
    );
  }

  List<ChartData> _prepareChartData() {
    final graphLeaderboard = Provider.of<LeaderboardProvider>(context);

    List<ChartData> chartData = [];

    if (graphLeaderboard.userPointsForGraph.isNotEmpty) {
      for (int i = 0; i < graphLeaderboard.userPointsForGraph.length; i++) {
        DateTime date = DateTime.parse(graphLeaderboard.userPointsForGraph.keys.elementAt(i));
        int points = graphLeaderboard.userPointsForGraph.values.elementAt(i);
        chartData.add(ChartData(date, points));
      }
    } else {
      DateTime now = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        DateTime date = now.subtract(Duration(days: i));
        chartData.add(ChartData(date, 0));
      }
    }

    return chartData;
  }
}

class ChartData {
  ChartData(this.date, this.points);
  final DateTime date;
  final int points;
}