import 'package:firebase_auth/firebase_auth.dart';
import 'package:classify/global/global.dart';
import 'package:flutter/foundation.dart';
import 'package:classify/data/services/google_login_service.dart';
class FirebaseAuthService {
  final FirebaseAuth _auth = firebaseAuth;

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential;
  }

  Future<UserCredential> signupWithGoogle() async {
    return await GoogleLoginService().signInWithGoogle();
  }

  Future<bool> loginWithGoogle() async {
    try {
      await GoogleLoginService().signInWithGoogle();
      return true;
    } catch (e) {
      debugPrint("❌ 구글 로그인 실패 in [loginWithGoogle method] in [firebase_auth_service]: $e");
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      await user.delete();
    } catch (e) {
      debugPrint("❌ 계정 삭제 실패 in [deleteAccount method] in [firebase_auth_service]: $e");
      rethrow;
    }
  }
}
