import 'dart:async';
import 'package:classify/data/repositories/sync/sync_monitor_repository.dart';
import 'package:classify/data/services/firestore_service.dart';
import 'package:classify/data/services/hive_service.dart';
import 'package:flutter/foundation.dart';

class SyncMonitorRepositoryRemote extends SyncMonitorRepository {
  final HiveService _hiveService;
  final FirestoreService _firestoreService;
  
  SyncMonitorRepositoryRemote({
    required HiveService hiveService,
    required FirestoreService firestoreService,
  }) : _hiveService = hiveService,
       _firestoreService = firestoreService;
  
  @override
  Stream<int> watchLocalMemoCount() {
    return _hiveService
        .watchMemos()
        .map((memos) => memos.length)
        .distinct();  // 중복 값 방지
  }
  
  @override
  Stream<int> watchServerMemoCount() {
    return _firestoreService
        .watchMemo()
        .map((snapshot) => snapshot.docs.length)
        .distinct();  // 중복 값 방지
  }
  
  @override
  int getLocalMemoCount() {
    return _hiveService.getMemos().length;
  }
  
  @override
  Future<int> getServerMemoCount() async {
    try {
      final serverMemos = await _firestoreService.getUserMemos();
      return serverMemos.length;
    } catch (e) {
      debugPrint('❌ 서버 메모 개수 조회 실패: $e');
      return 0;
    }
  }
} 