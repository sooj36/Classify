import 'dart:async';
import 'package:classify/data/repositories/sync/sync_monitor_repository.dart';
import 'package:flutter/foundation.dart';

/// 프로필 화면에 필요한 데이터를 관리하는 ViewModel
class ProfileViewModel extends ChangeNotifier {
  final SyncMonitorRepository _syncMonitorRepository;
  
  
  // 로컬/서버 메모 카운트 관리
  int _localMemoCount = 0;
  int _serverMemoCount = 0;
  
  // 스트림 구독 관리
  StreamSubscription? _localCountSubscription;
  StreamSubscription? _serverCountSubscription;
  
  // 에러 상태 관리
  String? _error;
  
  // 로딩 상태
  bool _isLoading = true;
  
  // Getters
  int get localMemoCount => _localMemoCount;
  int get serverMemoCount => _serverMemoCount;
  String? get error => _error;
  bool get isLoading => _isLoading;
  
  // 현재 사용자 정보
  
  ProfileViewModel({
    required SyncMonitorRepository syncMonitorRepository,
  }) : _syncMonitorRepository = syncMonitorRepository {
    _initSyncMonitor();
  }
  
  /// 동기화 모니터링 초기화
  void _initSyncMonitor() {
    _isLoading = true;
    notifyListeners();
    
    try {
      // 로컬 메모 수 구독
      _localCountSubscription = _syncMonitorRepository
          .watchLocalMemoCount()
          .listen((count) {
        _localMemoCount = count;
        _isLoading = false;
        notifyListeners();
        debugPrint('✅ 로컬 메모 카운트 업데이트: $_localMemoCount');
      }, onError: (e) {
        _error = '로컬 메모 모니터링 오류: $e';
        _isLoading = false;
        notifyListeners();
        debugPrint('❌ 로컬 메모 모니터링 오류: $e');
      });
      
      // 서버 메모 수 구독
      _serverCountSubscription = _syncMonitorRepository
          .watchServerMemoCount()
          .listen((count) {
        _serverMemoCount = count;
        _isLoading = false;
        notifyListeners();
        debugPrint('✅ 서버 메모 카운트 업데이트: $_serverMemoCount');
      }, onError: (e) {
        _error = '서버 메모 모니터링 오류: $e';
        _isLoading = false;
        notifyListeners();
        debugPrint('❌ 서버 메모 모니터링 오류: $e');
      });
    } catch (e) {
      _error = '모니터링 초기화 오류: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ 모니터링 초기화 오류: $e');
    }
  }
  
  /// 수동으로 서버 메모 수 갱신
  Future<void> refreshServerMemoCount() async {
    try {
      final count = await _syncMonitorRepository.getServerMemoCount();
      _serverMemoCount = count;
      notifyListeners();
    } catch (e) {
      _error = '서버 메모 수 갱신 오류: $e';
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    _localCountSubscription?.cancel();
    _serverCountSubscription?.cancel();
    super.dispose();
  }
} 