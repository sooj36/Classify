import 'package:flutter/foundation.dart';
import 'package:weathercloset/data/repositories/auth/auth_repository_remote.dart';

class SettingViewModel extends ChangeNotifier {
  final AuthRepositoryRemote _authRepository;

  SettingViewModel({
    required AuthRepositoryRemote authRepository,
  }) : _authRepository = authRepository;

  Future<bool> logout() async {
    return await _authRepository.logout();
  }

  Future<bool> deleteAccount() async {
    try {
      return await _authRepository.deleteAccount();
    } catch (e) {
      debugPrint('회원 탈퇴 중 오류 발생: $e');
      return false;
    }
  }
} 