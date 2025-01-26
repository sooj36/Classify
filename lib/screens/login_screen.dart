import 'package:weathercloset/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weathercloset/screens/signup_screen.dart';
import 'package:weathercloset/screens/root_screen.dart';
import 'package:provider/provider.dart';

class LoginUserModel {
  final String email;
  final bool rememberMe;

  LoginUserModel({
    required this.email,
    this.rememberMe = false,
  });
}

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

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ChangeNotifierProvider(
          create: (_) => LoginViewModel(
            LoginRepository(snapshot.data!),
          ),
          child: Consumer<LoginViewModel>(
            builder: (context, viewModel, _) {
              return Scaffold(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "WeatherCloset",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    loginForm(viewModel),
                    const SizedBox(height: 10),
                    if (viewModel.error != null)
                      Text(viewModel.error!, style: const TextStyle(color: Colors.red)),
                    buildButtons(context, viewModel),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

    Form loginForm(LoginViewModel viewModel) {
    // 컨트롤러 초기값 설정
    if (viewModel.savedEmail != null) {
      emailController.text = viewModel.savedEmail!;
    }

    return Form(
      child: Column(
        children: [
          CustomTextField(
            data: Icons.email,
            controller: emailController,
            hintText: "Email",  // 힌트는 기본값으로
            isObsecre: false,
          ),
          CustomTextField(
            data: Icons.lock,
            controller: passwordController,
            hintText: "비밀번호",
            isObsecre: true, 
          ),
          CheckboxListTile(
            title: const Text("이메일 저장"),
            value: viewModel.rememberMe,
            onChanged: (value) => viewModel.setRememberMe(value ?? false),
          ),
        ],
      ),
    );
  }


  Widget buildButtons(BuildContext context, LoginViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF68CAEA),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: viewModel.isLoading
                ? null
                : () async {
                    final success = await viewModel.login(
                      emailController.text,
                      passwordController.text,
                    );
                    
                    if (success && context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const RootScreen()),
                        (route) => false,
                      );
                    }
                  },
              child: viewModel.isLoading
                ? const CircularProgressIndicator()
                : const Text(
                    "로그인",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF68CAEA),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                );
              },
              child: const Text(
                "회원가입",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


