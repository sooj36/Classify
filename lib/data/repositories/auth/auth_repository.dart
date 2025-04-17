import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository extends ChangeNotifier {
  /// Returns true when the user is logged in
  /// Returns [Future] because it will load a stored auth state the first time.
  
  // Future<bool> get isAuthenticated;

  Future<bool> signupWithGoogle();

  Future<bool> loginWithGoogle();

  /// Perform login
  Future<bool> login({
    required String email,
    required String password,
  });

  /// Perform logout
  Future<bool> logout();

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  });

  Future<bool> deleteAccount();
}
