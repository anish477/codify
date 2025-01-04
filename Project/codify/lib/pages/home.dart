import 'package:flutter/material.dart';
import 'package:codify/services/auth.dart';

void main()=>runApp(const MaterialApp(

  home: Home(),
));

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _auth.signOut();
          },
          child: const Text('Logout'),
        ),
      ),



    );
  }
}


