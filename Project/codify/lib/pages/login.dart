import 'package:flutter/material.dart';



class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _loginState();
}

class _loginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),

      appBar: AppBar(
      backgroundColor: const Color(0xFFFFFFFF),

      ),
      body: Center(
        child: Column(

          children: <Widget>[

            const SizedBox(height: 20),


            const Text("Welcome Learner" ,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black),
            ),
            const SizedBox(height: 45),
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
            const SizedBox(height: 35),
            ElevatedButton(
              onPressed: (){

              },
                style: TextButton.styleFrom(
                side: const BorderSide(color: Colors.black, width: 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)
                ),
                  backgroundColor: const Color(0xFFFFFFFF),

                  minimumSize: const Size(250, 45)
              ),


              child: const Text("Login", style: TextStyle(color: Colors.black)

                ,

              ),

            ),
            const SizedBox(height: 35),


              const Text(" Log in with ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal,color: Colors.black54),
              ),

            const SizedBox(height: 25),

            SizedBox(
                height: 70,
                child: IconButton(onPressed: (){}, icon: Image.asset("assets/google.png") ,iconSize: 0.1,)),

            

           const SizedBox(height: 25),
            GestureDetector(
              onTap: (){
                Navigator.pushNamed(context, "/signup");
              },
              child: const Text("Dont have an account? Sign Up",style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal,color: Colors.black54),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
