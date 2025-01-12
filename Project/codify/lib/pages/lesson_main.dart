import 'package:flutter/material.dart ';

class LessonMain extends StatefulWidget {
  const LessonMain({super.key});

  @override
  State<LessonMain> createState() => _LessonMainState();
}

class _LessonMainState extends State<LessonMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lesson Main"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Lesson Main"),
          ],
        ),
      ),
    );
  }
}