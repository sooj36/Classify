import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:weathercloset/screens/root_screen.dart';
import '../../widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String status;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    this.status = "approved",
  });
}

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

class SignUpViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  
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

class SignupScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignUpViewModel(),
      child: Consumer<SignUpViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 55),
                  const Text("WeatherCloset", 
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  signUpForm(),
                  const SizedBox(height: 10),
                  if (viewModel.error != null)
                    Text(viewModel.error!, style: const TextStyle(color: Colors.red)),
                  signUpButton(context, viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Form signUpForm() {
    return Form(
      child: Column(
        children: [
          CustomTextField(
            data: Icons.person,
            controller: nameController,
            hintText: "이름",
            isObsecre: false,
          ),
          CustomTextField(
            data: Icons.email,
            controller: emailController,
            hintText: "이메일",
            isObsecre: false,
          ),
          CustomTextField(
            data: Icons.phone,
            controller: phoneController,
            hintText: "전화번호",
            isObsecre: false,
          ),
          CustomTextField(
            data: Icons.lock,
            controller: passwordController,
            hintText: "비밀번호",
            isObsecre: true,
          ),
          CustomTextField(
            data: Icons.lock,
            controller: confirmPasswordController,
            hintText: "비밀번호 확인",
            isObsecre: true,
          ),
        ],
      ),
    );
  }

  ElevatedButton signUpButton(BuildContext context, SignUpViewModel viewModel) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF68CAEA),
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
      ),
      onPressed: viewModel.isLoading
          ? null
          : () async {
              final success = await viewModel.signUp(
                email: emailController.text,
                password: passwordController.text,
                confirmPassword: confirmPasswordController.text,
                name: nameController.text,
                phone: phoneController.text,
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
          : const Text("가입신청",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}