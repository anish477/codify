import 'package:codify/provider/lives_provider.dart';
import 'package:codify/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../widget/categoryWidget.dart';
import '../widget/showStreak.dart';
import 'user_lesson_content.dart';
import '../provider/lesson_provider.dart';
import '../provider/user_stat_provider.dart';
import 'package:codify/lesson/topic.dart';
import 'package:codify/lesson/lesson.dart';
import '../widget/buildLivesDisplay.dart';
import '../services/auth.dart';
import '../user/redirect_add_profile.dart';
import '../user/user_service.dart';
import '../user/user.dart';

class LessonMain extends StatefulWidget {
  const LessonMain({super.key});

  @override
  State<LessonMain> createState() => _LessonMainState();
}

class _LessonMainState extends State<LessonMain>
    with AutomaticKeepAliveClientMixin<LessonMain> {
  static bool _dataLoadedBefore = false;
  static bool _isInitializing = false;

  String? _userId;
  bool _loadingUser = true;

  int? _previousLives;
  final NotificationService _notificationService = NotificationService();
  LivesProvider? _livesProvider;
  bool _listenersAdded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    if (!_dataLoadedBefore && !_isInitializing) {
      print("LessonMain: First-time initialization");
      _isInitializing = true;
      _loadData();
    } else {
      print("LessonMain: Skipping initialization - already done before");

      _loadingUser = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_listenersAdded && mounted) {
      _livesProvider = Provider.of<LivesProvider>(context, listen: false);
      _previousLives = _livesProvider!.lives?.currentLives;
      _livesProvider!.addListener(_onLivesChanged);
      _listenersAdded = true;
    }
  }

  void _onLivesChanged() {
    if (!mounted) return;

    final lives = Provider.of<LivesProvider>(context, listen: false).lives;
    final current = lives?.currentLives ?? 0;

    if (_previousLives == 0 && current > 0) {
      final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      _notificationService.scheduleLocalNotification(
        id: id,
        title: 'Lives Refilled!',
        body: 'Your lives have refilled. Come back and learn!',
        scheduledDateTime: DateTime.now().add(Duration(seconds: 1)),
        payload: 'lives_refilled',
      );
    }

    _previousLives = current;
  }

  @override
  void dispose() {
    _livesProvider?.removeListener(_onLivesChanged);
    super.dispose();
  }

  Future<void> _loadData() async {
    print("LessonMain: Starting _loadData");
    _userId = await AuthService().getUID();
    print(
        "LessonMain: User ID fetched: ${_userId != null ? 'available' : 'null'}");

    if (_userId != null) {
      final UserService _userService = UserService();
      final users = await _userService.getUserByUserId(_userId!);
      print("LessonMain: User profile fetched, exists: ${users.isNotEmpty}");

      if (users.isEmpty) {
        print(
            "LessonMain: No user profile found, redirecting to profile creation");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RedirectProfile()),
            );
          }
        });
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          print("LessonMain: Loading user stats");

          Provider.of<UserStatProvider>(context, listen: false)
              .getUserStats()
              .then((_) {
            print("LessonMain: User stats loaded successfully");
            if (mounted) {
              setState(() {
                _loadingUser = false;

                _dataLoadedBefore = true;
                _isInitializing = false;
                print("LessonMain: loadingUser set to false");
              });
            }
          }).catchError((error) {
            print("LessonMain ERROR: Error loading user stats: $error");
            if (mounted) {
              setState(() {
                _loadingUser = false;
                _isInitializing = false;
                print("LessonMain: loadingUser set to false after error");
              });
            }
          });
        }
      });
    } else {
      print("LessonMain: No user ID found");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _loadingUser = false;
            _isInitializing = false;
            print("LessonMain: loadingUser set to false (no user ID)");
          });
        }
      });
    }
  }

  void refreshData() {
    if (!mounted) return;
    setState(() {
      _loadingUser = true;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final lessonProvider = Provider.of<LessonProvider>(context);
    final livesProvider = Provider.of<LivesProvider>(context);
    final userStatProvider = Provider.of<UserStatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const CategoryDisplay(),
            const StreakDisplay(),
            const BuildLivesDisplay(),
          ],
        ),
      ),
      backgroundColor: Color(0xFFFFFFFF),
      body: _loadingUser
          ? _buildInitialLoadingUI()
          : lessonProvider.loading
              ? _buildLoadingUI()
              : lessonProvider.error != null
                  ? _buildErrorUI(lessonProvider.error!)
                  : lessonProvider.userLessons.isEmpty
                      ? const Center(child: Text("No categories to display"))
                      : _buildTopicAndLessonList(
                          lessonProvider, livesProvider, userStatProvider),
    );
  }

  Widget _buildInitialLoadingUI() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header shimmer
            Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 24),

            // Topics shimmer
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    height: 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicAndLessonList(LessonProvider lessonProvider,
      LivesProvider livesProvider, UserStatProvider userStatProvider) {
    if (lessonProvider.topics.isEmpty) {
      return const Center(child: Text("No topics available."));
    }

    return ListView.builder(
      itemCount: lessonProvider.topics.length,
      itemBuilder: (context, index) {
        final Topic topic = lessonProvider.topics[index];

        return _buildTopicItem(
            context, lessonProvider, topic, livesProvider, userStatProvider);
      },
    );
  }

  Widget _buildLoadingUI() {
    return Center(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF78E08F),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 100,
                    height: 20,
                    color: Colors.grey[300],
                  ),
                  const Icon(Icons.arrow_downward, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorUI(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              "Error: $error",
              style: const TextStyle(color: Colors.red, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicsList(LessonProvider lessonProvider,
      LivesProvider livesProvider, UserStatProvider userStatProvider) {
    return Column(
      children: lessonProvider.topics.map((Topic topic) {
        return _buildTopicItem(
            context, lessonProvider, topic, livesProvider, userStatProvider);
      }).toList(),
    );
  }

  Widget _buildTopicItem(
      BuildContext context,
      LessonProvider lessonProvider,
      Topic topic,
      LivesProvider livesProvider,
      UserStatProvider userStatProvider) {
    return GestureDetector(
      onTap: () {
        lessonProvider.toggleTopic(topic.documentId);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopicHeader(topic),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: topic.isExpanded
                  ? _buildLessonList(context, lessonProvider, topic,
                      livesProvider, userStatProvider)
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  final Map<String, _TopicColors> _topicColors = {
    "Writing Code": _TopicColors(
      headerColor: Color(0xFFFF8020),
      lessonColor: Color(0xFFFFC300),
    ),
    "Memory & Variable": _TopicColors(
      headerColor: Color(0xFF8549BA),
      lessonColor: Color(0xFFA560E8),
    ),
    "Numerical Data": _TopicColors(
      headerColor: Color(0xFFFA881B),
      lessonColor: Color(0xFFFF9400),
    ),
    "default": _TopicColors(
      headerColor: Color(0xFF7AC70C),
      lessonColor: Color(0xFF8EE000),
    ),
  };

  Widget _buildLessonList(
      BuildContext context,
      LessonProvider lessonProvider,
      Topic topic,
      LivesProvider livesProvider,
      UserStatProvider userStatProvider) {
    List<Lesson> lessons = lessonProvider.lessons
        .where((lesson) => lesson.topicId == topic.documentId)
        .toList();

    if (lessons.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text("No lessons available for this topic."),
      );
    }

    final completedLessonIds = userStatProvider.questionIds;

    bool allWritingCodeCompleted = false;
    Topic? writingTopic;
    for (var t in lessonProvider.topics) {
      if (t.name == 'Writing Code') {
        writingTopic = t;
        break;
      }
    }
    if (writingTopic != null) {
      final writingTopicId = writingTopic.documentId;
      final writingCodeLessons =
          lessonProvider.lessons.where((l) => l.topicId == writingTopicId);
      allWritingCodeCompleted = writingCodeLessons
          .every((l) => completedLessonIds.contains(l.documentId));
    }

    final Map<String, bool> lessonLockStatus = {};

    final List<String> specialTopics = ['Numerical Data', 'TextData', 'Call'];

    for (int i = 0; i < lessons.length; i++) {
      final lesson = lessons[i];

      if (topic.name == 'Memory & Variable' &&
          specialTopics.contains(topic.name)) {
        lessonLockStatus[lesson.documentId] = !allWritingCodeCompleted;
      } else if (i == 0) {
        lessonLockStatus[lesson.documentId] = false;
      } else {
        final previousLessonId = lessons[i - 1].documentId;
        lessonLockStatus[lesson.documentId] =
            !completedLessonIds.contains(previousLessonId);
      }
    }

    List<List<Lesson>> groupedLessons = _groupLessonsIntoRows(lessons, 3);
    List<Widget> rowWidgets = [];

    for (var lessonRow in groupedLessons) {
      rowWidgets.add(
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: lessonRow.asMap().entries.map((entry) {
              int index = entry.key;
              Lesson lesson = entry.value;
              bool isLocked = lessonLockStatus[lesson.documentId] ?? true;
              return _buildLessonItem(context, lesson, livesProvider,
                  lessonRow.length, index, topic, isLocked, userStatProvider);
            }).toList()),
      );
      rowWidgets.add(const SizedBox(height: 32));
    }

    return Column(
      children: rowWidgets,
    );
  }

  List<List<Lesson>> _groupLessonsIntoRows(List<Lesson> lessons, int rowSize) {
    List<List<Lesson>> groupedLessons = [];
    for (int i = 0; i < lessons.length; i += rowSize) {
      int end = (i + rowSize < lessons.length) ? i + rowSize : lessons.length;
      groupedLessons.add(lessons.sublist(i, end));
    }
    return groupedLessons;
  }

  Widget _buildTopicHeader(Topic topic) {
    final topicColors = _topicColors[topic.name] ?? _topicColors["default"]!;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 80,
          width: constraints.maxWidth,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: topicColors.headerColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(topic.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              _buildAnimatedArrow(topic),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedArrow(Topic topic) {
    return AnimatedRotation(
      duration: const Duration(milliseconds: 300),
      turns: topic.isExpanded ? 0.5 : 0,
      child: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
    );
  }

  Widget _buildLessonItem(
      BuildContext context,
      Lesson lesson,
      LivesProvider livesProvider,
      int rowLength,
      int index,
      Topic topic,
      bool isLocked,
      UserStatProvider userStatProvider) {
    final topicColors = _topicColors[topic.name] ?? _topicColors["default"]!;
    final bool isCompleted =
        userStatProvider.questionIds.contains(lesson.documentId);

    Color iconColor;
    IconData iconData;
    VoidCallback? onTapCallback;

    if (isLocked) {
      iconColor = Colors.grey[400]!;
      iconData = Icons.lock;
      onTapCallback = () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complete the previous lesson first!'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      };
    } else if (isCompleted) {
      iconColor = Colors.grey;
      iconData = Icons.check_circle;
      onTapCallback = () async {
        if (livesProvider.lives?.currentLives == 0) {
          _showNoLivesDialog(context);
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserLessonContent(
                  documentId: lesson.documentId, topicId: topic.documentId),
            ),
          );
          if (mounted && _userId != null) {
            Provider.of<UserStatProvider>(context, listen: false)
                .getUserStats();
          }
        }
      };
    } else {
      iconColor = topicColors.lessonColor;
      iconData = Icons.play_circle_fill;
      onTapCallback = () async {
        if (livesProvider.lives?.currentLives == 0) {
          _showNoLivesDialog(context);
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserLessonContent(
                  documentId: lesson.documentId, topicId: topic.documentId),
            ),
          );
          if (mounted && _userId != null) {
            Provider.of<UserStatProvider>(context, listen: false)
                .getUserStats();
          }
        }
      };
    }

    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            _buildDirectionalArrow(rowLength, index, isLocked),
            _circleIcon(
              iconData,
              iconColor,
              onTap: onTapCallback,
            ),
          ],
        ),
        Text(
          lesson.questionName,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isLocked ? Colors.grey[600] : Colors.black),
        ),
      ],
    );
  }

  Widget _buildDirectionalArrow(int rowLength, int index, bool nextIsLocked) {
    if (index == rowLength - 1) {
      return const SizedBox();
    }
    return Positioned(
        right: -20,
        child: Icon(Icons.arrow_forward_rounded,
            color: Colors.grey[400], size: 28));
  }

  Widget _circleIcon(IconData icon, Color bgColor, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 28),
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

class _TopicColors {
  final Color headerColor;
  final Color lessonColor;

  _TopicColors({required this.headerColor, required this.lessonColor});
}
