import 'package:flutter/material.dart';

/// 로컬과 서버의 메모 개수를 실시간으로 모니터링하기 위한 Repository
abstract class SyncMonitorRepository extends ChangeNotifier {
  /// 로컬 메모 개수를 스트림으로 반환
  Stream<int> watchLocalMemoCount();
  
  /// 서버 메모 개수를 스트림으로 반환
  Stream<int> watchServerMemoCount();
  
  /// 현재 로컬 메모 개수 반환
  int getLocalMemoCount();
  
  /// 현재 서버 메모 개수 반환
  Future<int> getServerMemoCount();
} 