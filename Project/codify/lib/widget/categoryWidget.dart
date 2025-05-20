import 'package:codify/provider/lesson_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryDisplay extends StatefulWidget {
  const CategoryDisplay({super.key});

  @override
  State<CategoryDisplay> createState() => _CategoryDisplayState();
}

class _CategoryDisplayState extends State<CategoryDisplay>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  bool _isOverlayVisible = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _showOverlay(BuildContext context) {
    if (_isOverlayVisible) return;

    final overlay = Overlay.of(context);
    final appBarHeight = Scaffold.of(context).appBarMaxHeight ?? 0;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(children: [
        Positioned.fill(child: GestureDetector(
          onTap: () {
            _hideOverlay();
          },
        )),
        Positioned(
          top: appBarHeight,
          right: 0,
          child: SlideTransition(
            position: _slideAnimation,
            child: Material(
              color: Colors.transparent,
              child: _buildOverlayContent(context),
            ),
          ),
        ),
      ]),
    );

    overlay.insert(_overlayEntry!);
    _isOverlayVisible = true;
    _animationController.forward();
  }

  void _hideOverlay() {
    if (_overlayEntry != null && _isOverlayVisible) {
      _animationController.reverse().then((_) {
        _overlayEntry!.remove();
        _overlayEntry = null;
        _isOverlayVisible = false;
      });
    }
  }

  Widget _buildOverlayContent(BuildContext context) {
    final lessonProvider = Provider.of<LessonProvider>(context, listen: false);

    final List<String> allCategories = lessonProvider.userLessons
        .map((e) => e.userCategoryName ?? "No Name")
        .toList();

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Choose Lesson",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    _hideOverlay();
                  },
                ),
              ],
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: allCategories.map((category) {
                return _buildCategoryCard(category, lessonProvider);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String category, LessonProvider lessonProvider) {
    bool isSelected = lessonProvider.selectedCategoryName == category;

    final matchingLesson = lessonProvider.userLessons.firstWhere(
      (lesson) => lesson.userCategoryName == category,
      orElse: () => lessonProvider.userLessons.first,
    );

    return GestureDetector(
      onTap: () {
        if (matchingLesson.userCategoryId != null) {
          print(
              "Selecting category: $category with ID: ${matchingLesson.userCategoryId}");

          lessonProvider.selectCategory(
              category, matchingLesson.userCategoryId!);
          _hideOverlay();
        }
      },
      child: Card(
        color: isSelected ? Colors.blue[200] : Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(category),
        ),
      ),
    );
  }

  Widget _buildSelectedCategoryCard(
      String category, LessonProvider lessonProvider) {
    return GestureDetector(
      onTap: () {
        lessonProvider.toggleCategory(category);
      },
      child: Card(
        color: Colors.blue[100],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(category),
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () {
                  lessonProvider.toggleCategory(category);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hideOverlay();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lessonProvider = Provider.of<LessonProvider>(context);

    final String displayText =
        lessonProvider.selectedCategoryName ?? " Choose Lesson";

    print("Selected category: ${lessonProvider.selectedCategoryName}");

    return GestureDetector(
      onTap: () {
        if (_isOverlayVisible) {
          _hideOverlay();
        } else {
          _showOverlay(context);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              Text(
                displayText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, color: Colors.black87),
            ],
          ),
        ],
      ),
    );
  }
}
