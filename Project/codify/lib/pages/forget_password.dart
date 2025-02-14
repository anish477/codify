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
      backgroundColor: const Color(0xFFFFFFFF), // Set background color
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), // Set app bar color
        elevation: 0, // Remove shadow
        iconTheme: const IconThemeData(color: Colors.black), // Set back button color
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
                      // You might want to add more robust email validation here
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
                          await _auth.sendPasswordResetEmail(email);
                          // Show a success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Password reset email sent. Check your inbox.'),
                            ),
                          );
                          Navigator.pop(context); // Go back to the login screen
                        } catch (e) {
                          setState(() {
                            error = e.toString().replaceAll('Exception: ', '');
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
}