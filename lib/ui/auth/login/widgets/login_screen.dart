import 'package:weathercloset/utils/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:weathercloset/routing/routes.dart';
import 'package:weathercloset/ui/basics/root_screen.dart';
import 'package:weathercloset/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  final LoginViewModel viewModel;

  const LoginScreen({super.key, required this.viewModel});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "WeatherCloset",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          loginForm(widget.viewModel),
          const SizedBox(height: 10),
          if (widget.viewModel.error != null)
            Text(
              widget.viewModel.error!, 
              style: const TextStyle(color: Colors.red),
            ),
          buildButtons(context, widget.viewModel),
        ],
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
            value: widget.viewModel.rememberMe,
            onChanged: (value) => widget.viewModel.setRememberMe(value ?? false),
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
              onPressed: widget.viewModel.isLoading
                ? null
                : () async {
                    final success = await widget.viewModel.login(
                      emailController.text,
                      passwordController.text,
                    );
                    
                    if (success && context.mounted) {
                      context.go(Routes.home);
                    }
                  },
              child: widget.viewModel.isLoading
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


