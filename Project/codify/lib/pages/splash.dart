import 'package:flutter/material.dart';
import 'package:codify/pages/signup.dart';
import 'package:codify/pages/login.dart';

void main()=>runApp(const MaterialApp(
  home: Splash(),
));

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color(0xFFF9C222),
      body:Column(
        children: <Widget>[
          const SizedBox(height: 135),
          const Image(image: AssetImage("assets/logo.png"),),

          const Text("Codify",style: TextStyle(fontSize: 100,fontWeight: FontWeight.w800,color: Colors.black,fontStyle: FontStyle.italic,letterSpacing:6),),

          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: ElevatedButton(
                style: TextButton.styleFrom(
                    side: const BorderSide(color: Colors.black, width: 2),
                    //reduce curve of button
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)

                    ),
                    backgroundColor: const Color(0xFFFFFFFF),


                    minimumSize: const Size(325, 50)
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const Login()));
                },
                child:  const Text('Login',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black),



                ),


              ),

            ),


          ),
          const SizedBox(height: 25),
          // Text("Dont have an account? Sign Up",style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal,color: Colors.black54),
          //
          // ),
          GestureDetector(
            onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>const Signup()));

            },
            child: const Text("Dont have an account? Sign Up",style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal,color: Colors.black54),
            ),
          ),


        ],
      ),
    );
  }
}

