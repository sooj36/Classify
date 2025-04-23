import 'package:flutter/material.dart';
import 'package:weathercloset/data/repositories/auth/auth_repository.dart';
  
class LoginViewModel extends ChangeNotifier {
  LoginViewModel({
    required AuthRepository authRepository,
  })  :
    // Repositories are manually assigned because they're private members.
    _authRepository = authRepository {
      _initializeEmail();
    }

  final AuthRepository _authRepository;
  
  bool _isLoading = false;
  String? _error;
  bool _rememberMe = false;
  String? _savedEmail;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get rememberMe => _rememberMe;
  String? get savedEmail => _savedEmail;

  void _initializeEmail() {
    _savedEmail = _authRepository.getSavedEmail();
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
      await _authRepository.login(email: email, password: password);
      await _authRepository.saveEmail(email, _rememberMe);
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

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authRepository.loginWithGoogle();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = "구글 로그인 실패";
      _isLoading = false;
      notifyListeners();
      debugPrint("❌ 구글 로그인 실패 in [loginWithGoogle method] in [login_viewmodel]: $e");
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