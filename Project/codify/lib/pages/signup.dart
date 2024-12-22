
import 'package:flutter/material.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _signupState();
}

class _signupState extends State<Signup> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),

      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text("Start Learning"),
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
            SizedBox(height: 25),
            SizedBox(
              width: 350,
              height: 40,
              child: TextField(

                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  hintText: "Enter  name",
                  labelText: "Name",
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
                  hintText: "Enter  age",
                  labelText: "Age",
                ),
              ),
            ),
        SizedBox(height: 35),
            ElevatedButton(
              style: TextButton.styleFrom(
                  side: const BorderSide(color: Colors.black, width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)
                  ),
                  backgroundColor: Color(0xFFFFFFFF),
                  minimumSize: Size(250, 50)
              ),
              onPressed: (){ Navigator.pushNamed(context, "/login");},
              child: Text("Sign Up",style: TextStyle(
                color: Colors.black,
              ),),
            ),

            SizedBox(height: 35),
            Text("Sign Up with",style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal,color: Colors.black54),
            ),
            SizedBox(
              height: 20,
            ),

            SizedBox(
                height: 70,
                child: IconButton(onPressed: (){}, icon: Image.asset("assets/google.png") ,iconSize: 0.1,)),

            SizedBox(height: 30),

            Text("Already have an account? Login",style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal,color: Colors.black54),
            ),

          ],
        ),
      ),
    );
  }
}