import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:weathercloset/domain/models/auth/signup_user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    // Firebase Auth 계정 생성
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    debugPrint("✅ Firebase 계정 생성: ${userCredential.user!.uid}");

    final user = UserModel(
      uid: userCredential.user!.uid,
      email: email,
      name: name,
      phone: phone,
    );

    // Firestore에 사용자 데이터 저장
    await _firestore.collection("users").doc(user.uid).set({
      "userUID": user.uid,
      "userEmail": user.email,
      "userName": user.name,
      "phone": user.phone,
      "status": user.status,
    });
    debugPrint("✅ Firestore 데이터 저장 완료");

    return user;
  }
}