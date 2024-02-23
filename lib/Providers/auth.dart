import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authService = Provider<AuthService>((ref) => AuthService());

enum AuthState { authenticated, unauthenticated, loading }

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final authStateProvider = StreamProvider<AuthState>(
      (ref) => ref.watch(authService).authStateChanges());

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<AuthState> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser != null) {
        return AuthState.authenticated;
      } else {
        return AuthState.unauthenticated;
      }
    });
  }

//Email/Password sign-in
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return true;
    } catch (e) {
      return false;
    }
  }

  //sign up
  Future<bool> signUpWithEmailAndPassword(Map<String, dynamic> data) async {
    String email = data['email'];
    String password = data['password'];
    try {
      UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (credential.user!.uid.isNotEmpty) {
        data.remove("password");
        await _firestore.collection("users").add(data);
        await credential.user!.updateDisplayName(data['name']);
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  //log out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  //password reset
  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // is email verified
  bool isEmailVerified() {
    final user = _firebaseAuth.currentUser;
    return user != null ? user.emailVerified : false;
  }

  //verify email
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }
}
