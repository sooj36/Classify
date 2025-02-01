import 'package:weathercloset/utils/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:weathercloset/routing/routes.dart';
import 'package:weathercloset/ui/basics/root_screen.dart';
import 'package:weathercloset/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginViewModel _viewModel;

  LoginScreen({super.key, required LoginViewModel viewModel}) :
    _viewModel = viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "WeatherCloset",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          loginForm(_viewModel),
          const SizedBox(height: 10),
          if (_viewModel.error != null)
            Text(
              _viewModel.error!, 
              style: const TextStyle(color: Colors.red),
            ),
          buildButtons(context, _viewModel),
        ],
      ),
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
            hintText: "Email",
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
                context.go(Routes.signup);
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


