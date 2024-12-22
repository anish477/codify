import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';



class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _loginState();
}

class _loginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),

      appBar: AppBar(
      backgroundColor: Color(0xFFFFFFFF),

      ),
      body: Center(
        child: Column(

          children: <Widget>[


            Text("Welcome Learner" ,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black),
            ),
            SizedBox(height: 35),
            SizedBox(
              width: 350,
              height: 40,
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  hintText: "Enter your email",
                  labelText: "Email",
                ),
              ),
            ),
            SizedBox(height: 25),
            SizedBox(
              width: 350,
              height: 40,
              child: TextField(


                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  hintText: "Enter your password",
                  labelText: "Password",
                ),
              ),
            ),
            SizedBox(height: 35),
            ElevatedButton(
              onPressed: (){

              },
                style: TextButton.styleFrom(
                side: const BorderSide(color: Colors.black, width: 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)
                ),
                  backgroundColor: Color(0xFFFFFFFF),

                  minimumSize: Size(250, 45)
              ),


              child: Text("Login", style: TextStyle(color: Colors.black)

                ,

              ),

            ),
            SizedBox(height: 35),


              Text(" Log in with ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal,color: Colors.black54),
              ),

            SizedBox(height: 25),

            SizedBox(
                height: 70,
                child: IconButton(onPressed: (){}, icon: Image.asset("assets/google.png") ,iconSize: 0.1,)),

            

           SizedBox(height: 25),
            GestureDetector(
              onTap: (){
                Navigator.pushNamed(context, "/signup");
              },
              child: Text("Dont have an account? Sign Up",style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal,color: Colors.black54),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
