import 'package:flutter/material.dart';
import 'package:classify/routing/routes.dart';
import 'package:classify/utils/custom_text_field.dart';
import 'package:classify/ui/auth/signup/view_models/signup_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:classify/utils/top_level_setting.dart';

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
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // 상단 반원형 배경
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Text(
                  "classify",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          // 회원가입 카드
          Positioned(
            top: MediaQuery.of(context).size.height * 0.32,
            left: 20,
            right: 20,
            bottom: 20,
            child: SingleChildScrollView(
              child: Card(
                elevation: 8,
                shadowColor: AppTheme.decorationColor1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "회원가입",
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "classify에 가입하고 이용해보세요.",
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 24),
                      signUpForm(),
                      const SizedBox(height: 8),
                      if (_viewModel.error != null)
                        Text(
                          _viewModel.error!,
                          style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.errorColor),
                        ),
                      const SizedBox(height: 20),
                      signUpButton(context, _viewModel),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(child: Divider(color: AppTheme.decorationColor1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "또는 다음으로 회원가입",
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                          const Expanded(child: Divider(color: AppTheme.decorationColor1)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      buildGoogleSignUpButton(context, _viewModel),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            context.go(Routes.login);
                          },
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(fontSize: 14),
                              children: [
                                TextSpan(
                                  text: "이미 계정이 있으신가요? ",
                                  style: TextStyle(color: AppTheme.textColor2),
                                ),
                                TextSpan(
                                  text: "로그인",
                                  style: TextStyle(
                                    color: AppTheme.secondaryColor1,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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

  Widget signUpButton(BuildContext context, SignUpViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 1,
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
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                "가입신청",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Widget buildGoogleSignUpButton(BuildContext context, SignUpViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          icon: Icons.email,
          backgroundColor: const Color(0xFFDD4B39),
          onPressed: viewModel.isLoading
              ? null
              : () async {
                  final success = await viewModel.signUpWithGoogle();
                  if (success && context.mounted) {
                    context.go(Routes.sendMemo);
                  }
                },
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}