import 'package:weathercloset/data/services/firebase_auth_service.dart';
import 'package:weathercloset/data/services/firestore_service.dart';
import 'package:weathercloset/data/repositories/auth/auth_repository.dart';
import 'package:weathercloset/domain/models/auth/signup_user_model.dart';
import 'package:flutter/material.dart';
import 'package:weathercloset/global/global.dart';
import 'package:weathercloset/data/services/hive_service.dart';

class AuthRepositoryRemote extends AuthRepository {
  AuthRepositoryRemote({
    required FirebaseAuthService firebaseAuthService,
    required FirestoreService firestoreService,
    required HiveService hiveService,
  }) : _firebaseAuthService = firebaseAuthService,
       _firestoreService = firestoreService,
       _hiveService = hiveService;

  final FirebaseAuthService _firebaseAuthService;
  final FirestoreService _firestoreService;
  final HiveService _hiveService;

  @override
  Future<bool> login({required String email, required String password}) async {
    try {
      final userCredential = await _firebaseAuthService.login(email: email, password: password);
      debugPrint("✅ 로그인 성공: ${userCredential.user!.uid}");
      return true;
    } catch (e) {
      debugPrint("❌ 로그인 실패 in [login method] in [auth_repository_remote]: $e");
      return false;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _firebaseAuthService.logout();
      debugPrint("✅ 로그아웃 성공");
      return true;
    } catch (e) {
      debugPrint("❌ 로그아웃 실패 in [logout method] in [auth_repository_remote]: $e");
      return false;
    }
  }

  @override
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final userCredential = await _firebaseAuthService.signUp(
        email: email,
        password: password,
      );
      final user = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        phone: phone,
        status: "active",
      );
      await _firestoreService.createUser(user: user);
      debugPrint("✅ 회원가입 성공: ${user.uid}");
      await _firestoreService.createCategoryWhenSignup();
      debugPrint("✅ 서버 측에 카테고리 생성 성공");
      _hiveService.createCategoryWhenSignup();
      debugPrint("✅ 로컬 측에 카테고리 생성 성공");
      return true;
    } catch (e) {
      debugPrint("❌ 회원가입 실패 in [signUp method] in [auth_repository_remote]: $e");
      return false;
    }
  }

  @override
  Future<bool> deleteAccount() async {
    try {
      await _firestoreService.deleteUser();
      await _firebaseAuthService.deleteAccount();
      debugPrint("✅ 계정 삭제 성공");
      return true;
    } catch (e) {
      debugPrint("❌ 계정 삭제 실패 in [deleteAccount method] in [auth_repository_remote]: $e");
      return false;
    }
  }

  Future<void> saveEmail(String email, bool remember) async {
    final prefs = sharedPreferences;
    if (remember) {
      await prefs!.setString("savedEmail", email);
      debugPrint("✅ 이메일 저장됨: $email");
    } else {
      await prefs!.remove("savedEmail");
      debugPrint("✅ 저장된 이메일 삭제됨");
    }
  }

  String? getSavedEmail() {
    return sharedPreferences!.getString("savedEmail");
  }
}

