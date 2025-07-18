import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return cred.user;
    } catch (e) {
      print("Sign Up Error: $e");
      return null;
    }
  }

  Future<User?> loginWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return cred.user;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  Future<UserCredential?> loginWithGoogle() async{
    try{
      final googleUser = await GoogleSignIn().signIn();

      final googleAuth = await googleUser?.authentication;

      final cred = GoogleAuthProvider.credential(idToken: googleAuth?.idToken,accessToken: googleAuth?.accessToken);

      return await _auth.signInWithCredential(cred);

    }catch(e){
      print(':::::::::: ERROR in google Login : ${e.toString()}');
    }
    return null;
  }


  Future<void> signOut() async {
    await _auth.signOut();
  }
}