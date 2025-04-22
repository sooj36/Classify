import 'package:weathercloset/utils/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:weathercloset/routing/routes.dart';
import 'package:weathercloset/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:weathercloset/utils/top_level_setting.dart';

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
    final theme = Theme.of(context);
    
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
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
                      "Classify",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              // 로그인 카드
              Positioned(
                top: MediaQuery.of(context).size.height * 0.32,
                left: 20,
                right: 20,
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
                          "로그인",
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Classify에 오신 것을 환영합니다.",
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 24),
                        loginForm(widget.viewModel),
                        const SizedBox(height: 8),
                        if (widget.viewModel.error != null)
                          Text(
                            widget.viewModel.error!, 
                            style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.errorColor),
                          ),
                        const SizedBox(height: 20),
                        loginButton(context, widget.viewModel),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Expanded(child: Divider(color: AppTheme.decorationColor1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "또는 다음으로 로그인",
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                            const Expanded(child: Divider(color: AppTheme.decorationColor1)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        buildSocialLoginButtons(context, widget.viewModel),
                        const SizedBox(height: 24),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              context.go(Routes.signup);
                            },
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: "계정이 없으신가요? ",
                                    style: TextStyle(color: AppTheme.textColor2),
                                  ),
                                  TextSpan(
                                    text: "회원가입",
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF8BC34A), size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF757575),
            fontSize: 13,
          ),
        ),
      ],
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
          Transform.translate(
            offset: const Offset(-10, 0),
            child: CheckboxListTile(
              title: const Text(
                "로그인 상태 유지",
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textColor1,
                ),
              ),
              checkColor: Colors.white,
              activeColor: AppTheme.primaryColor,
              value: widget.viewModel.rememberMe,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (value) => widget.viewModel.setRememberMe(value ?? false),
            ),
          ),
        ],
      ),
    );
  }

  Widget loginButton(BuildContext context, LoginViewModel viewModel) {
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
              final success = await viewModel.login(
                emailController.text,
                passwordController.text,
              );
              if (success && context.mounted) {
                context.go(Routes.today);
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
              "로그인",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
      ),
    );
  }

  Widget buildSocialLoginButtons(BuildContext context, LoginViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          icon: Icons.email,
          backgroundColor: const Color(0xFFDD4B39),
          onPressed: viewModel.isLoading
            ? null
            : () async {
                final success = await viewModel.loginWithGoogle();
                if (success && context.mounted) {
                  context.go(Routes.today);
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


