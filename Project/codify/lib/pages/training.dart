import 'package:flutter/material.dart';

class Training extends StatefulWidget {
  const Training({super.key});

  @override
  State<Training> createState() => _TrainingState();
}

class _TrainingState extends State<Training> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Training"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Training"),
          ],
        ),
      ),
    );
  }
}