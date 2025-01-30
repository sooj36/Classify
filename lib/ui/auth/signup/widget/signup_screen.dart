import 'package:flutter/material.dart';
import 'package:weathercloset/ui/basics/root_screen.dart';
import '../../../../utils/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:weathercloset/ui/auth/signup/view_models/signup_viewmodel.dart';

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