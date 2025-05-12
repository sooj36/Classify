import 'package:flutter/material.dart';
import 'package:classify/global/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:classify/utils/top_level_setting.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // 현재 로그인된 사용자 정보 가져오기
    final User? user = firebaseAuth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("로그인된 사용자 정보가 없습니다"),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // 프로필 이미지
              CircleAvatar(
                radius: 60,
                backgroundColor: AppTheme.primaryColor.withAlpha(1),
                backgroundImage:
                    user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                child: user.photoURL == null
                    ? const Icon(Icons.person,
                        size: 60, color: AppTheme.primaryColor)
                    : null,
              ),

              const SizedBox(height: 20),

              // 사용자 이름
              Text(
                user.displayName ?? "이름 없음",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              const Divider(),

              // 계정 정보 섹션
              _buildInfoSection("계정 정보"),

              _buildInfoTile(
                icon: Icons.email_outlined,
                title: "이메일",
                subtitle: user.email ?? "이메일 없음",
              ),

              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 20),

              // 인증 정보 섹션
              _buildInfoSection("인증 정보"),

              _buildInfoTile(
                icon: Icons.login_outlined,
                title: "인증 방식",
                subtitle: user.providerData.isNotEmpty
                    ? user.providerData
                        .map((provider) => provider.providerId)
                        .join(", ")
                    : "알 수 없음",
              ),

              _buildInfoTile(
                icon: Icons.calendar_today_outlined,
                title: "계정 생성일",
                subtitle: user.metadata.creationTime != null
                    ? _formatDateTime(user.metadata.creationTime!)
                    : "알 수 없음",
              ),

              _buildInfoTile(
                icon: Icons.schedule_outlined,
                title: "마지막 로그인",
                subtitle: user.metadata.lastSignInTime != null
                    ? _formatDateTime(user.metadata.lastSignInTime!)
                    : "알 수 없음",
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.additionalColor,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 ${dateTime.hour}:${dateTime.minute}";
  }
}
