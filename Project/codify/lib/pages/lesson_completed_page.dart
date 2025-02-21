import 'package:flutter/material.dart';
import '../gamification/streak.dart';
import '../gamification/streak_service.dart';
import '../services/auth.dart';

class LessonCompletedPage extends StatefulWidget {
  const LessonCompletedPage({super.key});

  @override
  State<LessonCompletedPage> createState() => _LessonCompletedPageState();
}

class _LessonCompletedPageState extends State<LessonCompletedPage> {
  final StreakService _streakService = StreakService();
  final AuthService _auth = AuthService();
  Streak? _streak;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStreakData();
  }

  Future<void> _fetchStreakData() async {
    final user = await _auth.getUID();
    if (user != null) {
      final streak = await _streakService.getStreakForUser(user);
      if (mounted) {
        setState(() {
          _streak = streak;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lesson Completed"),
        // backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(

            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.check_circle_outline,
                size: 100,
                color: Colors.green,
              ),
              const SizedBox(height: 30),
              const Text(
                "Congratulations! You've completed the lesson.",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator(),
              if (_streak != null && !_isLoading)
                Column(
                  children: [
                    Text(
                      'Current Streak: ${_streak!.currentStreak}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const SizedBox(height: 10),
                    // Text(
                    //   'Longest Streak: ${_streak!.longestStreak}',
                    //   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                    // ),
                    const SizedBox(height: 20),
                  ],
                )
              else if (!_isLoading)
                const Text(
                  'No streak data found.',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  // backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
