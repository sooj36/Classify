import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkMonitorService {
  static final NetworkMonitorService _instance = NetworkMonitorService._internal();
  factory NetworkMonitorService() => _instance;
  NetworkMonitorService._internal();
  
  final _connectivity = Connectivity();
  bool _isConnected = false;
  
  // 네트워크 상태 변화 스트림 - 오프라인에서 온라인으로 변경될 때만 알림
  Stream<bool> get connectionStream => _connectivity.onConnectivityChanged
      .map<bool>((result) => _processConnectivityChange(result.last))
      .where((isRestored) => isRestored);
  
  // 연결 상태 변화 처리
  bool _processConnectivityChange(ConnectivityResult result) {
    final wasConnected = _isConnected;
    _isConnected = result != ConnectivityResult.none;
    
    // 오프라인 → 온라인 전환 여부를 반환
    return !wasConnected && _isConnected;
  }
  
  // 초기 연결 상태 확인
  Future<void> initialize() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = result != ConnectivityResult.none;
  }
}