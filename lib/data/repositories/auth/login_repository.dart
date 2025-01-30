import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class LoginRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SharedPreferences _prefs;

  LoginRepository(this._prefs);

  Future<UserCredential> login(String email, String password) async {
    debugPrint("✅ 로그인 시도: $email");
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> saveEmail(String email, bool remember) async {
    if (remember) {
      await _prefs.setString("savedEmail", email);
      debugPrint("✅ 이메일 저장됨: $email");
    } else {
      await _prefs.remove("savedEmail");
      debugPrint("✅ 저장된 이메일 삭제됨");
    }
  }

  String? getSavedEmail() {
    return _prefs.getString("savedEmail");
  }
}