import 'package:codify/pages/signup.dart';
import 'package:flutter/material.dart';
import 'package:codify/services/auth.dart';
import 'forget_password.dart';

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
  bool _passwordVisible = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 20),
                  const Text(
                    "Welcome Learner",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 45),
                  SizedBox(
                    width: double.infinity,
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        hintText: "Enter your email",
                        labelText: "Email",
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 20.0),
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
                    width: double.infinity,
                    child: TextFormField(
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        hintText: "Enter your password",
                        labelText: "Password",
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 20.0),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
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
                          if (mounted) {
                            setState(() {
                              isLoading = true;
                              error = '';
                            });
                          }
                          dynamic user = await _auth
                              .loginUserWithEmailAndPassword(email, password);

                          if (mounted) {
                            setState(() {
                              isLoading = false;
                              if (user is String) {
                                error = user;
                              } else if (user == null) {
                                error =
                                    'Could not sign in with those credentials.';
                              } else {
                                print(
                                    '[Login Page] Email/Password login successful. Calling _scheduleLoginNotification...');
                              }
                            });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        side: const BorderSide(color: Colors.black, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        backgroundColor: const Color(0xFFFFFFFF),
                        minimumSize: const Size(250, 45),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                  if (error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        error,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 14.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 35),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgotPassword()),
                      );
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Log in with",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: Colors.black54),
                  ),
                  const SizedBox(height: 25),
                  InkWell(
                    onTap: () async {
                      if (mounted) {
                        setState(() {
                          isLoading = true;
                          error = '';
                        });
                      }
                      dynamic user = await _auth.signInWithGoogle();

                      if (mounted) {
                        setState(() {
                          isLoading = false;
                          if (user == null) {
                            error = 'Google sign-in failed';
                          } else {
                            print(
                                '[Login Page] Google Sign-In successful. Calling _scheduleLoginNotification...');
                          }
                        });
                      }
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          image: AssetImage("assets/google.png"),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Signup()));
                    },
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
