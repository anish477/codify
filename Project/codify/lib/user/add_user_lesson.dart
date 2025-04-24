import 'package:flutter/material.dart';
import "package:codify/lesson/category_service.dart";
import '../lesson/category.dart';
import "user_lesson_service.dart";
import "../services/auth.dart";
import "user_lesson.dart";
import 'package:shimmer/shimmer.dart';

class AddUserLesson extends StatefulWidget {
  const AddUserLesson({super.key});

  @override
  State<AddUserLesson> createState() => _AddUserLessonState();
}

class _AddUserLessonState extends State<AddUserLesson> {
  final CategoryService _categoryService = CategoryService();
  List<Category> _categories = [];
  List<String> _addedCategoryIds = [];
  String? SelectedCatergory;
  String? SelectedDocumnetId;
  int length = 0;

  bool isLoading = true;
  String? errorMessage;
  final UserLessonService _userLessonService = UserLessonService();
  final AuthService _auth = AuthService();
  bool _isAddingLesson = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text(
          "Add Lesson",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFFFFF),
      ),
      body: Container(
        child: isLoading
            ? Center(
                child: Shimmer.fromColors(
                  highlightColor: Colors.grey,
                  baseColor: Colors.white,
                  child: ListView.builder(
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Container(
                          height: 50.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            : errorMessage != null
                ? Center(
                    child: Text(
                      "Error: $errorMessage",
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : _categories.isEmpty
                    ? Center(
                        child: const Text(
                          "No more lessons to add",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            color: const Color(0xFFFFFFFF),
                            elevation: 5,
                            child: ListTile(
                              title: Text(
                                _categories[index].name,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                setState(() {
                                  if (SelectedCatergory !=
                                      _categories[index].name) {
                                    SelectedCatergory = _categories[index].name;
                                    SelectedDocumnetId =
                                        _categories[index].documentId;
                                  }
                                });
                                _addUserLesson();
                              },
                            ),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                      ),
      ),
    );
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _categoryService.getAllCategories();
      final String? userId = await _auth.getUID();
      List<UserLesson> existingLessons = [];
      if (userId != null) {
        existingLessons =
            await _userLessonService.getUserLessonByUserId(userId);
        _addedCategoryIds =
            existingLessons.map((lesson) => lesson.userCategoryId!).toList();
      }

      if (mounted) {
        setState(() {
          _categories = categories
              .where((category) =>
                  !_addedCategoryIds.contains(category.documentId))
              .toList();
          if (_categories.isNotEmpty && SelectedCatergory == null) {
            SelectedCatergory = _categories[0].name;
            SelectedDocumnetId = _categories[0].documentId;
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Failed to load categories: ${e.toString()}";
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage ?? "Error fetching categories")),
        );
      }
    }
  }

  Future<void> _addUserLesson() async {
    setState(() {
      _isAddingLesson = true;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final String? userId = await _auth.getUID();
      if (userId == null) {
        _isAddingLesson = false;
        if (mounted) {
          Navigator.of(context).pop();
        }
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error: User not logged in")));
        return;
      }

      final UserLesson userLesson = UserLesson(
        documentId: "",
        userId: userId,
        userCategoryId: SelectedDocumnetId,
        userCategoryName: SelectedCatergory,
      );
      await _userLessonService.addUserLesson(userLesson);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error adding lesson: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingLesson = false;
        });
        Navigator.of(context).pop();
      }
    }
  }
}
