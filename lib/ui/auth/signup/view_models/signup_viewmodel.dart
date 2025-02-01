
import 'package:flutter/material.dart';
import 'package:weathercloset/data/repositories/auth/auth_repository_remote.dart';


class SignUpViewModel extends ChangeNotifier {
  final AuthRepositoryRemote _repository;

  SignUpViewModel({required AuthRepositoryRemote authRepositoryRemote})
  : _repository = authRepositoryRemote;
  
  bool _isLoading = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> signUp({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
    required String phone,
  }) async {
    if (!_validateInputs(password, confirmPassword, email, name)) {
      debugPrint("❌ 입력값 검증 실패");
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      _isLoading = false;
      notifyListeners();
      debugPrint("✅ 회원가입 완료");
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint("❌ 회원가입 실패: $e");
      return false;
    }
  }

  bool _validateInputs(String password, String confirmPassword, String email, String name) {
    if (password != confirmPassword) {
      _error = "비밀번호가 일치하지 않습니다.";
      notifyListeners();
      return false;
    }
    if (email.isEmpty || name.isEmpty || password.isEmpty) {
      _error = "모든 정보를 입력해주세요.";
      notifyListeners();
      return false;
    }
    return true;
  }
}