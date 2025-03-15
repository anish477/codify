import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'training_mistake.dart';
import '../user/user_mistake_service.dart';
import '../services/auth.dart';

class Training extends StatefulWidget {
  const Training({super.key});

  @override
  State<Training> createState() => _TrainingState();
}

class _TrainingState extends State<Training> {
  final UserMistakeService _userMistakeService = UserMistakeService();
  final AuthService _auth = AuthService();
  int _totalMistakes = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTotalMistakes();
  }

  Future<void> _fetchTotalMistakes() async {
    try {
      final userId = await _auth.getUID();
      final mistakes = await _userMistakeService.getUserMistakes(userId!);

      if (mounted) {
        setState(() {
          _totalMistakes = mistakes.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching total mistakes: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Training",style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Color(0xFFFFFFFF),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrainingMistake(),
                  ),
                );
              },
              child: _isLoading
                  ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Your Mistake",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,

                        ),
                      ),
                      Text(
                        "$_totalMistakes",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Your Mistake",
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Text(
                      "$_totalMistakes",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}