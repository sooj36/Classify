import 'package:flutter/material.dart';
import 'package:classify/global/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:classify/utils/top_level_setting.dart';
import 'package:classify/ui/profile/profile_view_model.dart';

class ProfileScreen extends StatefulWidget {
  final ProfileViewModel viewmodel;
  const ProfileScreen({super.key, required this.viewmodel});

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
        child: ListenableBuilder(
          listenable: widget.viewmodel,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  
                  // 프로필 이미지
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppTheme.primaryColor.withAlpha(1),
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? const Icon(Icons.person, size: 60, color: AppTheme.primaryColor)
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
                  
                  // 이메일 (이름 바로 아래 회색으로 작게)
                  Text(
                    user.email ?? "이메일 없음",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),
                  
                  // 동기화 모니터링 섹션
                  _buildInfoSection("동기화 상태"),
                  
                  // 로컬 메모 수
                  _buildInfoTile(
                    icon: Icons.storage_outlined,
                    title: "로컬 메모 개수",
                    subtitle: "${widget.viewmodel.localMemoCount}개",
                    color: Colors.blue,
                  ),
                  
                  // 서버 메모 수
                  _buildInfoTile(
                    icon: Icons.cloud_outlined,
                    title: "서버 메모 개수",
                    subtitle: "${widget.viewmodel.serverMemoCount}개",
                    color: Colors.green,
                  ),
                  
                  // 동기화 상태 카드
                  _buildSyncStatusCard(),
                  
                  const SizedBox(height: 20),
                  
                  // 새로고침 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => widget.viewmodel.refreshServerMemoCount(),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text("서버 새로고침", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppTheme.primaryColor,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
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
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color color = AppTheme.primaryColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(50),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 동기화 상태 카드 위젯
  Widget _buildSyncStatusCard() {
    final localCount = widget.viewmodel.localMemoCount;
    final serverCount = widget.viewmodel.serverMemoCount;
    bool isSynced = localCount == serverCount;
    
    String statusText = isSynced
        ? "동기화 완료"
        : "동기화 필요 (차이: ${(localCount - serverCount).abs()}개)";
    
    IconData statusIcon = isSynced 
        ? Icons.check_circle 
        : Icons.sync_problem;
    
    Color statusColor = isSynced 
        ? Colors.green 
        : Colors.orange;
        
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              statusIcon,
              color: statusColor,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                      fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}