import 'package:flutter/material.dart';
import 'package:classify/routing/routes.dart';
import 'package:classify/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:classify/utils/top_level_setting.dart';

class LoginScreen extends StatefulWidget {
  final LoginViewModel viewModel;

  const LoginScreen({super.key, required this.viewModel});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
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
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "classify",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "AI 기반 메모 관리",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // 로그인 카드
              Positioned(
                top: MediaQuery.of(context).size.height * 0.35,
                left: 20,
                right: 20,
                child: Card(
                  elevation: 8,
                  shadowColor: AppTheme.decorationColor1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "소셜 로그인",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor1,
                          ),
                        ),
                        if (widget.viewModel.error != null)
                          Text(
                            widget.viewModel.error!, 
                            style: const TextStyle(
                              color: AppTheme.errorColor,
                              fontSize: 14,
                            ),
                          ),
                        const SizedBox(height: 24),
                        googleLoginButton(context, widget.viewModel),
                        const SizedBox(height: 30),
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

  Widget googleLoginButton(BuildContext context, LoginViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.grey, width: 0.5),
          ),
          elevation: 1,
        ),
        onPressed: viewModel.isLoading
          ? null
          : () async {
              final success = await viewModel.loginWithGoogle();
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
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons8-구글-로고-144.png',
                  height: 24,
                  width: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  "Google로 계속하기",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}


