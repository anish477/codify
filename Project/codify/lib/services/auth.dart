import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  Future<String?> getUID() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      print("User is not authenticated.");
    }
    return null;
  }

  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Error during Google sign-in: $e");
      return null;
    }
  }

  Future<Object?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
    } catch (e) {
      print("Error during email/password sign-up: $e");
      return null;
    }
    return null;
  }

  Future<Object?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else {
        return 'Email or Password Invalid';
      }
    }
    return null;
  }

  Future<void> signOut(BuildContext context) async {
    try {
      final navigatorState = Navigator.of(context);

      await FirebaseAuth.instance.signOut();
      print("User signed out successfully!");

      try {
        await _googleSignIn.signOut();
      } catch (e) {
        print("Error signing out from Google: $e");
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigatorState.context.mounted) {
          Phoenix.rebirth(navigatorState.context);
        }
      });
    } catch (e) {
      print("Error signing out: $e");
      rethrow;
    }
  }

  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'auth/ invalid-email') {
        return 'No user found for that email.';
      } else {
        return ' ${e.message}';
      }
    } catch (e) {
      return 'An error occurred: $e';
    }
    return '';
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in';
      }

      final String? email = user.email;
      if (email == null) {
        throw 'User email is not available';
      }

      final AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw 'Current password is incorrect';
      } else if (e.code == 'weak-password') {
        throw 'New password is too weak';
      } else if (e.code == 'requires-recent-login') {
        throw 'Please sign in again before changing your password';
      } else {
        throw 'Error: ${e.message}';
      }
    } catch (e) {
      throw 'Failed to change password: $e';
    }
  }
}
