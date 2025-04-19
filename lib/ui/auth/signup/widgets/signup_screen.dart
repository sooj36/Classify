import 'package:flutter/material.dart';
import 'package:weathercloset/routing/routes.dart';
import 'package:weathercloset/utils/custom_text_field.dart';
import 'package:weathercloset/ui/auth/signup/view_models/signup_viewmodel.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final SignUpViewModel _viewModel;

  SignupScreen({super.key, required SignUpViewModel viewModel}) :
    _viewModel = viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 55),
            const Text(
              "Classify",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            signUpForm(),
            const SizedBox(height: 10),
            if (_viewModel.error != null)
              Text(
                _viewModel.error!,
                style: const TextStyle(color: Colors.red),
              ),
            signUpButton(context, _viewModel),
            const SizedBox(height: 20),
            buildGoogleSignUpButton(context, _viewModel),
          ],
        ),
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
                context.go(Routes.sendMemo);
              }
            },
      child: viewModel.isLoading
          ? const CircularProgressIndicator()
          : const Text("가입신청",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget buildGoogleSignUpButton(BuildContext context, SignUpViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.email, color: Colors.white),
        label: const Text(
          "구글 계정으로 회원가입",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 12),
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: viewModel.isLoading
            ? null
            : () async {
                final success = await viewModel.signUpWithGoogle();
                if (success && context.mounted) {
                  context.go(Routes.sendMemo);
                }
              },
      ),
    );
  }
}