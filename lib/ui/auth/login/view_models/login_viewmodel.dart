import 'package:flutter/material.dart';
import 'package:weathercloset/data/repositories/auth/login_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginRepository _repository;
  
  bool _isLoading = false;
  String? _error;
  bool _rememberMe = false;
  String? _savedEmail;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get rememberMe => _rememberMe;
  String? get savedEmail => _savedEmail;

  LoginViewModel(this._repository) {
    _initializeEmail();
  }

  void _initializeEmail() {
    _savedEmail = _repository.getSavedEmail();
    if (_savedEmail != null) {
      _rememberMe = true;
      notifyListeners();
    }
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    if (!_validateInputs(email, password)) {
      debugPrint("❌ 입력값 검증 실패");
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.login(email, password);
      await _repository.saveEmail(email, _rememberMe);
      _isLoading = false;
      notifyListeners();
      debugPrint("✅ 로그인 성공");
      return true;
    } catch (e) {
      _error = "로그인 실패: 이메일과 비밀번호를 확인해주세요";
      _isLoading = false;
      notifyListeners();
      debugPrint("❌ 로그인 실패: $e");
      return false;
    }
  }

  bool _validateInputs(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      _error = "이메일과 비밀번호를 입력해주세요.";
      notifyListeners();
      return false;
    }
    return true;
  }
}