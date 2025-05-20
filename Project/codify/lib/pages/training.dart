import 'package:codify/provider/lives_provider.dart';
import 'package:codify/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'training_mistake.dart';
import '../user/user_mistake_service.dart';
import '../services/auth.dart';

class Training extends StatefulWidget {
  const Training({super.key});

  @override
  State<Training> createState() => _TrainingState();
}

class _TrainingState extends State<Training>
    with AutomaticKeepAliveClientMixin<Training> {
  final UserMistakeService _userMistakeService = UserMistakeService();
  final AuthService _auth = AuthService();
  int _totalMistakes = 0;
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchTotalMistakes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _fetchTotalMistakes();
  }

  Future<void> _fetchTotalMistakes() async {
    try {
      final userId = await _auth.getUID();

      final count = await _userMistakeService.getQuestionCount(userId!);

      if (mounted) {
        setState(() {
          _totalMistakes = count;
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
    super.build(context);
    final livesProvider = Provider.of<LivesProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Training",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                if (livesProvider.lives?.currentLives == 0) {
                  _showNoLivesDialog(context);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrainingMistake(),
                    ),
                  ).then((_) {
                    _fetchTotalMistakes();
                  });
                }
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
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

  void _showNoLivesDialog(BuildContext context) {
    final livesProvider = Provider.of<LivesProvider>(context, listen: false);
    final notificationService = NotificationService();

    DateTime? nextRefillTime = livesProvider.lives?.lastRefillTime;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          title:
              const Text('No Lives Left', style: TextStyle(color: Colors.red)),
          content: const Text(
              'You have run out of lives. We\'ll notify you when they refill.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                if (nextRefillTime != null &&
                    nextRefillTime.isAfter(DateTime.now())) {
                  final notificationId =
                      DateTime.now().millisecondsSinceEpoch.remainder(100000);

                  try {
                    await notificationService.scheduleLocalNotification(
                      id: notificationId,
                      title: 'Lives Refilled!',
                      body: 'Your lives have refilled. Come back and learn!',
                      scheduledDateTime: nextRefillTime,
                      payload: 'lives_refilled',
                    );
                    print(
                        'Scheduled lives refill notification for $nextRefillTime');
                  } catch (e) {
                    print("Error scheduling notification: $e");
                  }
                } else {
                  print(
                      "No valid future refill time available to schedule notification.");
                }
              },
            ),
          ],
        );
      },
    );
  }
}
