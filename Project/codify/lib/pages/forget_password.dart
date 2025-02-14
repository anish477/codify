import 'package:flutter/material.dart';
import 'package:codify/services/auth.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String error = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(

              children: <Widget>[
                const Text(
                  "Reset Password",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
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
                      hintText: 'Enter your email',
                      labelText: 'Email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      // Email format validation
                      if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
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
                const SizedBox(height: 35),
                if (isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true;
                          error = '';
                        });

                        try {
                          final data = await _auth.sendPasswordResetEmail(email);

                          setState(() {
                            isLoading = false;
                          });


                          if (data.isEmpty) {
                            _showDialog();
                          } else {
                            setState(() {
                              error = data;
                            });
                          }
                        } catch (e) {
                          setState(() {
                            isLoading = false;
                            error = 'An error occurred. Please try again.';
                          });
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                      side: const BorderSide(color: Colors.black, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      backgroundColor: Colors.white,
                      minimumSize: const Size(250, 45),
                    ),
                    child: const Text(
                      'Send Reset Email',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                const SizedBox(height: 28),
                if (error.isNotEmpty)
                  Text(
                    error,
                    style: const TextStyle(color: Colors.red, fontSize: 14.0),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Link sent!'),
          content: const Text('Password reset email sent. Check your inbox.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop();

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}