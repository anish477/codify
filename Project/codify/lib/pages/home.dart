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
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.fitness_center), label: 'Traning'),
          NavigationDestination(icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),

        ],
        
        ),

      
     
      
      body:  Column(
          
          children: <Widget>[
           
          ],
        ),
      



    );
  }
}


