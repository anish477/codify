import 'package:codify/pages/home.dart';
import 'package:flutter/material.dart';
import '../user/add_user_lesson.dart';
import "../user/user_lesson_service.dart";
import '../services/auth.dart';
import '../user/user_lesson.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import '../provider/lesson_provider.dart';

class RedirectAddCourse extends StatefulWidget {
  const RedirectAddCourse({super.key});

  @override
  State<RedirectAddCourse> createState() => _AddCourseState();
}

class _AddCourseState extends State<RedirectAddCourse> {
  final UserLessonService _userLessonService = UserLessonService();
  final AuthService _auth = AuthService();
  List<UserLesson> _userLesson = [];

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserLessson();
  }

  Future<void> _fetchUserLessson() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      final String? userId = await _auth.getUID();
      if (userId == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = "User is not logged in.";
          });
        }
        return;
      }

      final userLesson = await _userLessonService.getUserLessonByUserId(userId);
      if (mounted) {
        setState(() {
          _userLesson = userLesson;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load courses: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteUserLesson(String documentId) async {
    try {
      await _userLessonService.deleteUserLesson(documentId);
      _fetchUserLessson();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting course: ${e.toString()}")),
        );
      }
    }
  }

  void _showDeleteConfirmationDialog(String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          title: const Text("Delete Course"),
          content: const Text("Are you sure you want to delete this course?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteUserLesson(documentId);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleNextButtonPress() async {
    if (_userLesson.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add at least one course before proceeding"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final lessonProvider =
          Provider.of<LessonProvider>(context, listen: false);
      await lessonProvider.refresh();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
    } catch (e) {
      if (mounted) {
        print("Error: $e");

        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text("Course",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFFFFF),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddUserLesson()),
                  ).then((value) => _fetchUserLessson());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58CC02),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Add Course"),
              ),
            ),
            SizedBox(height: 10),
            if (_isLoading)
              Expanded(
                child: Center(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: ListView.builder(
                      itemCount: 4,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Container(
                          width: double.infinity,
                          height: 50.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: <Widget>[
                    if (_userLesson.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          itemCount: _userLesson.length,
                          itemBuilder: (context, index) {
                            final lesson = _userLesson[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: const Color(0xFFFFFFFF),
                              elevation: 5,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(
                                      lesson.userCategoryName ??
                                          'Unknown Lesson Name',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _showDeleteConfirmationDialog(
                                              lesson.documentId),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    if (_userLesson.isEmpty &&
                        !_isLoading &&
                        _errorMessage == null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            const Text(
                              "No courses added yet",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Please add at least one course to continue",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleNextButtonPress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text("Next"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
