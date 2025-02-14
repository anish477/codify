import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Error during Google sign-in: $e");
      return null;
    }
  }

  Future<Object?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    }on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return'The account already exists for that email.';
      }
    }
    catch (e) {
      print("Error during email/password sign-up: $e");
      return null;
    }
    return null;
  }

  Future<Object?> loginUserWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    }on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      }
      // else{
      //   // Handle other FirebaseAuthException cases
      //   return '${e.message}';
      // }
      else{
        return 'Email or Password Invalid';
      }



    }
    return null;
    // catch (e) {
    //   print("Error during email/password sign-in: ${e.message}");
    //   return null;
    // }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();

    } catch (e) {
      print("Error during sign-out: $e");
    }
  }
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {

      if (e.code == 'auth/user-not-found') {
        throw Exception('No user found for that email.');
      } else {
        throw Exception('An error occurred: ${e.message}');
      }
    } catch (e) {
      // Handle other exceptions
      throw Exception('An error occurred: $e');
    }
  }


}

