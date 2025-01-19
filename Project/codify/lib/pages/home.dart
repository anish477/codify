import 'package:flutter/material.dart';
import 'package:codify/services/auth.dart';
import 'package:codify/pages/profile.dart';
import 'package:codify/pages/training.dart';
import 'package:codify/pages/leaderboard.dart';
import 'package:codify/pages/lesson_main.dart';
import 'package:lucide_icons/lucide_icons.dart';



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
          NavigationDestination(selectedIcon: Icon(LucideIcons.home,),icon:  Icon(LucideIcons.home,color: Colors.amber) , label: 'Home'),
          NavigationDestination(selectedIcon: Icon(LucideIcons.dumbbell),icon:  Icon(LucideIcons.dumbbell,color: Colors.blue,) , label: 'Traning'),
          NavigationDestination(selectedIcon: Icon(LucideIcons.award), icon:Icon(LucideIcons.award,color: Colors.green) , label: 'Leaderboard'),
          NavigationDestination(selectedIcon: Icon(LucideIcons.user), icon: Icon(LucideIcons.user,color: Colors.redAccent), label: 'Profile'),

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


