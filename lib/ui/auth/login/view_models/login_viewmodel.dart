import 'package:flutter/material.dart';
import 'package:weathercloset/data/repositories/auth/auth_repository_remote.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({
    required AuthRepositoryRemote authRepositoryRemote,
  })  :
    // Repositories are manually assigned because they're private members.
    _authRepositoryRemote = authRepositoryRemote {
      _initializeEmail();
    }

  final AuthRepositoryRemote _authRepositoryRemote;
  
  bool _isLoading = false;
  String? _error;
  bool _rememberMe = false;
  String? _savedEmail;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get rememberMe => _rememberMe;
  String? get savedEmail => _savedEmail;

  void _initializeEmail() {
    _savedEmail = _authRepositoryRemote.getSavedEmail();
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
      debugPrint("❌ 입력값 검증 실패 in [login method] in [login_viewmodel]");
      return false;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authRepositoryRemote.login(email: email, password: password);
      await _authRepositoryRemote.saveEmail(email, _rememberMe);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = "로그인 실패: 이메일과 비밀번호를 확인해주세요";
      _isLoading = false;
      notifyListeners();
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