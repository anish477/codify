import 'package:flutter/material.dart';

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
      backgroundColor:Color(0xFFF9C222),
      body:Column(
        children: <Widget>[
          SizedBox(height: 135),
          Image(image: AssetImage("assets/logo.png"),),

          Text("Codify",style: TextStyle(fontSize: 80,fontWeight: FontWeight.w800,color: Colors.black,fontStyle: FontStyle.italic,letterSpacing:2),),

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
                    backgroundColor: Color(0xFFFFFFFF),


                    minimumSize: Size(325, 50)
                ),
                onPressed: () {
                  Navigator.pushNamed(context, "/login");
                },
                child:  const Text('Login',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black),



                ),


              ),

            ),


          ),
          SizedBox(height: 25),
          // Text("Dont have an account? Sign Up",style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal,color: Colors.black54),
          //
          // ),
          GestureDetector(
            onTap: (){
              Navigator.pushNamed(context, "/signup");
            },
            child: Text("Dont have an account? Sign Up",style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal,color: Colors.black54),
            ),
          ),


        ],
      ),
    );
  }
}

