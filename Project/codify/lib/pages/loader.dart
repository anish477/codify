import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoaderState();
}

class _LoaderState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/codify.png"),
            SizedBox(height: 10),
            const Text(
              "Codify",
              style: TextStyle(
                  fontSize: 100,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 6),
            ),
          ],
        ),
      ),
    );
  }
}
