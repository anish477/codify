import 'package:flutter/material.dart';
import 'package:codify/services/auth.dart';
import 'package:codify/pages/profile.dart';
import 'package:codify/pages/training.dart';
import 'package:codify/pages/leaderboard.dart';
import 'package:codify/pages/lesson_main.dart';



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
  int currentPageIndex=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: NavigationBar(onDestinationSelected: (int index){
          setState(() {
            currentPageIndex=index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const [
          NavigationDestination(selectedIcon: Icon(Icons.home),icon:  Icon(Icons.home) , label: 'Home'),
          NavigationDestination(selectedIcon: Icon(Icons.fitness_center),icon:  Icon(Icons.fitness_center) , label: 'Traning'),
          NavigationDestination(selectedIcon: Icon(Icons.leaderboard), icon:Icon(Icons.leaderboard) , label: 'Leaderboard'),
          NavigationDestination(selectedIcon: Icon(Icons.person), icon: Icon(Icons.person), label: 'Profile'),

        ],
        
        ),

      
     
      
      body:  <Widget>[
         LessonMain(),
        Training(),
         Leaderboard(),
      
        Profile(),



      ][currentPageIndex],
      



    );
  }
}


