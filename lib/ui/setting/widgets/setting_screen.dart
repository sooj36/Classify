import 'package:classify/utils/top_level_setting.dart';
import 'package:flutter/material.dart';
import 'package:classify/routing/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:classify/ui/setting/view_models/setting_viewmodel.dart';

class SettingScreen extends StatelessWidget {
  final SettingViewModel viewModel;

  const SettingScreen({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.logout),
            iconColor: AppTheme.additionalColor.withOpacity(0.8),
            title: const Text('로그아웃'),
            onTap: () => _logout(context),
          ),
          ListTile(
            leading: const Icon(Icons.person_off),
            iconColor: AppTheme.additionalColor.withOpacity(0.8),
            title: const Text('회원 탈퇴'),
            onTap: () => _showDeleteConfirmDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            iconColor: AppTheme.additionalColor.withOpacity(0.8),
            title: const Text('개인정보처리방침'),
            onTap: () => _navigateToPrivacyPolicy(context),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final success = await viewModel.logout();
    if (success && context.mounted) {
      context.go(Routes.login);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그아웃 중 오류가 발생했습니다')),
      );
    }
  }

  Future<void> _showDeleteConfirmDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('회원 탈퇴'),
          content: const Text('정말로 탈퇴하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final success = await viewModel.deleteAccount();
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('회원 탈퇴가 완료되었습니다')),
                  );
                  context.go(Routes.login);
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('회원 탈퇴 중 오류가 발생했습니다')),
                  );
                }
              },
              child: const Text('탈퇴', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _navigateToPrivacyPolicy(BuildContext context) {
    context.push(Routes.privacyPolicy);
  }
}
