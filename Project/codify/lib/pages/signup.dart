import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String email = '';
  String password = '';
  String error = '';
  bool isLoading = false; // Add a loading state
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
              const Text(
                "Start Learning",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: 350,
                height: 40,
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
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
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
                height: 40,
                child: TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    hintText: "Enter your password",
                    labelText: "Password",
                  ),validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                    return 'Password must contain at least one uppercase letter';
                  }
                  if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
                    return 'Password must contain at least one lowercase letter';
                  }
                  if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
                    return 'Password must contain at least one digit';
                  }
                  if (!RegExp(r'(?=.*[@$!%*?&])').hasMatch(value)) {
                    return 'Password must contain at least one special character';
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
              if (isLoading) const CircularProgressIndicator() else ElevatedButton(
                style: TextButton.styleFrom(
                    side: const BorderSide(color: Colors.black, width: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    backgroundColor: const Color(0xFFFFFFFF),
                    minimumSize: const Size(250, 40)),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    setState(() {
                      isLoading = true; // Start loading
                      error = ''; // Clear any previous errors
                    });
                    try {
                      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );

                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    } on FirebaseAuthException catch (error) {
                      setState(() {
                        this.error = error.message ?? 'An unknown error occurred';
                      });
                    }  finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  }
                },
                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
              const SizedBox(height: 35),
              const Text(
                "Sign Up with",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: Colors.black54),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                  height: 70,
                  child: IconButton(
                    onPressed: () {
                      // Add Google Sign-In logic here
                    },
                    icon: Image.asset("assets/google.png"),
                    iconSize: 0.1,
                  )),
              const SizedBox(height: 30),
              const Text(
                "Already have an account? Login",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}