
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
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),

      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const Text("Start Learning",
            style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black),
            ),
            const SizedBox(height: 35),
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
            const SizedBox(height: 25),

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
            const SizedBox(height: 25),
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
            const SizedBox(height: 25),
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
        const SizedBox(height: 35),
            ElevatedButton(
              style: TextButton.styleFrom(
                  side: const BorderSide(color: Colors.black, width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)
                  ),
                  backgroundColor: const Color(0xFFFFFFFF),
                  minimumSize: const Size(250, 40)
              ),
              onPressed: (){ Navigator.pushNamed(context, "/login");},
              child: const Text("Sign Up",style: TextStyle(
                color: Colors.black,
              ),),
            ),

            const SizedBox(height: 35),
            const Text("Sign Up with",style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal,color: Colors.black54),
            ),
            const SizedBox(
              height: 20,
            ),

            SizedBox(
                height: 70,
                child: IconButton(onPressed: (){}, icon: Image.asset("assets/google.png") ,iconSize: 0.1,)),

            const SizedBox(height: 30),

            const Text("Already have an account? Login",style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal,color: Colors.black54),
            ),

          ],
        ),
      ),
    );
  }
}