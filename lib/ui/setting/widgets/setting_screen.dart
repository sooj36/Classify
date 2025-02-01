import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weathercloset/global/global.dart';
import 'package:weathercloset/routing/routes.dart';
import 'package:go_router/go_router.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

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
            title: const Text('로그아웃'),
            onTap: _logout,
          ),
          ListTile(
            leading: const Icon(Icons.person_off),
            title: const Text('회원 탈퇴'),
            onTap: _showDeleteConfirmDialog,
          ),
        ],
      ),
    );
  }
  
  Future<void> _logout() async {
    await firebaseAuth.signOut();
    if (mounted && context.mounted) {
      context.go(Routes.login);
    }
  }

  Future<void> _deleteAccount() async {
    try {
      User? user = firebaseAuth.currentUser;
      if (user != null) {
        // Firestore에서 사용자 데이터 삭제
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .delete();
        
        // Firebase Auth에서 사용자 삭제
        await user.delete();
        
        // SharedPreferences 데이터 삭제
        await sharedPreferences?.clear();
        
        if (mounted && context.mounted) {
          context.go(Routes.login);
        }
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원 탈퇴 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('회원 탈퇴'),
          content: const Text('정말로 탈퇴하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount();
              },
              child: const Text('탈퇴', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

}