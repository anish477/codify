import 'package:codify/pages/signup.dart';
import 'package:flutter/material.dart';
import 'package:codify/services/auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthService _auth = AuthService();

  String email = '';
  String password = '';
  String error = '';
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              const Text(
                "Welcome Learner",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 45),
              SizedBox(
                width: 350,
                height: 60,
                child: TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    hintText: "Enter your email",
                    labelText: "Email",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: 350,
                height: 60,
                child: TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    hintText: "Enter your password",
                    labelText: "Password",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 35),
              if (isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      final user = await _auth.loginUserWithEmailAndPassword(email, password);
                      if (user == null) {
                        setState(() {
                          error = 'Could not sign in with those credentials';
                          isLoading = false;
                        });
                      }
                    }
                  },
                  style: TextButton.styleFrom(
                    side: const BorderSide(color: Colors.black, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    backgroundColor: const Color(0xFFFFFFFF),
                    minimumSize: const Size(250, 45),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              SizedBox(
                height: 28,
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontSize: 14.0),
                ),
              ),
              const SizedBox(height: 35),
              const Text(
                "Log in with",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.black54),
              ),
              const SizedBox(height: 25),
              SizedBox(
                height: 70,
                child: IconButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    final user = await _auth.signInWithGoogle();
                    if (user == null) {
                      setState(() {
                        error = 'Google sign-in failed';
                        isLoading = false;
                      });
                    }
                  },
                  icon: Image.asset("assets/google.png"),
                  iconSize: 0.1,
                ),
              ),
              const SizedBox(height: 25),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Signup()));
                },
                child: const Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}