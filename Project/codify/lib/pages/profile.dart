import 'package:cached_network_image/cached_network_image.dart';
import 'package:codify/pages/add_course.dart';
import 'package:codify/pages/add_profile.dart';
import 'package:codify/pages/change_password.dart';

import 'package:codify/provider/streak_provider.dart';
import 'package:codify/provider/lesson_provider.dart';

import 'package:codify/pages/badge_page.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

import '../widget/fullScreenImage.dart';
import 'package:codify/provider/profile_provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile>
    with AutomaticKeepAliveClientMixin<Profile> {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileProvider>().fetchData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = context.watch<ProfileProvider>();
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        body: provider.isLoading
            ? _buildShimmerProfile(context)
            : NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowIndicator();
                  return true;
                },
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: provider.user != null
                      ? _buildProfileContent(provider, context)
                      : const Center(
                          child: Text('No user data available'),
                        ),
                ),
              ),
      ),
    );
  }

  Widget _buildProfileContent(ProfileProvider provider, BuildContext context) {
    final streak = Provider.of<StreakProvider>(context).streak;

    final lessonProv = Provider.of<LessonProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAvatar(provider, context),
          const SizedBox(height: 20),
          Text(
            provider.user!.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Age: ${provider.user!.age}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          Text('Current Streak: ${streak?.currentStreak ?? 0} Days',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text('Longest Streak', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('${streak?.longestStreak ?? 0} Days',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                children: [
                  const Text('Courses Enrolled',
                      style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('${lessonProv.userLessons.length}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTrendGraph(provider),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.person, color: Colors.green),
                    title: const Text("Profile"),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddProfile()));
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey, width: 2)),
                  child: ListTile(
                    leading: Icon(Icons.book, color: Colors.blue),
                    title: const Text("Course"),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AddCourse()));
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Badges page navigation
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey, width: 2)),
                  child: ListTile(
                    leading: Icon(Icons.emoji_events, color: Colors.amber),
                    title: const Text("My Badges"),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BadgePage()),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey, width: 2)),
                  child: ListTile(
                    leading: Icon(Icons.password, color: Colors.blue),
                    title: const Text("Change Password"),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChangePassword()));
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 50),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      provider.signOut(context);
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(40, 50),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Logout"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ProfileProvider provider, BuildContext context) {
    final imageUrl = provider.images.isNotEmpty
        ? provider.images.first.image
        : 'https://cdn-icons-png.flaticon.com/512/3177/3177283.png';
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FullScreenImage(imageUrl: imageUrl),
            ),
          ),
          child: Hero(
            tag: 'profileImage',
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.amber,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.fill,
                  height: 120,
                  width: 120,
                  placeholder: (c, u) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child:
                        Container(width: 120, height: 120, color: Colors.white),
                  ),
                  errorWidget: (c, u, e) =>
                      const Icon(Icons.error, color: Colors.red, size: 120),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: -7,
          right: 0,
          child: IconButton(
            onPressed: () => provider.pickAndUploadImage(context),
            icon: const Icon(Icons.edit, color: Colors.blue, size: 30),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendGraph(ProfileProvider provider) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3)),
        ],
      ),
      child: provider.graphDataLoaded
          ? SfCartesianChart(
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
                  dataSource: provider.chartData,
                  xValueMapper: (d, _) => d.date,
                  yValueMapper: (d, _) => d.points,
                  color: Colors.blueAccent,
                  width: 3,
                  markerSettings: const MarkerSettings(
                      isVisible: true, height: 8, width: 8, color: Colors.blue),
                ),
              ],
              plotAreaBorderWidth: 0,
            )
          : Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget _buildShimmerProfile(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 20),
            Container(width: 150, height: 20, color: Colors.white),
            const SizedBox(height: 10),
            Container(width: 100, height: 16, color: Colors.white),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(width: 80, height: 16, color: Colors.white),
                Container(width: 80, height: 16, color: Colors.white),
              ],
            ),
            const SizedBox(height: 20),
            Container(height: 200, width: double.infinity, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
