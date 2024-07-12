import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  // getting the current state of user
  Stream<User?> get authStateChange => _firebaseAuth.authStateChanges();

  Future<void> signInWithGoogle() async {
    // if platform is web
    if (kIsWeb) {
      try {
        if (kDebugMode) {
          print("Web platform detected.");
        }
        // Create a new provider
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('https://www.googleapis.com/auth/userinfo.profile');
        // Once signed in, return the UserCredential
        await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } catch (e) {
        if (kDebugMode) {
          print("Error occurred: $e");
        }
      }
    } else {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser =
          await (GoogleSignIn(scopes: ['email', "https://www.googleapis.com/auth/userinfo.profile"]).signIn());

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      // Create a new credential
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      ) as GoogleAuthCredential;
      await FirebaseAuth.instance.signInWithCredential(credential);
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _firebaseAuth.signOut();
  }

  User? getCurrentUser() => _firebaseAuth.currentUser;
}
