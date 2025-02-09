import 'package:flutter/material.dart';
import '../../../../data/repositories/cloth_analyze/cloth_repository_remote.dart';
import '../../../../domain/models/cloth/cloth_model.dart';


//StreamBuilder를 사용하지 않고 데이터를 캐시하여 사용하였음
//화면을 전환하면 Stream으로부터 새 데이터가 오기 전까지는 데이터를 표시하지 않기 때문
class ClosetViewModel extends ChangeNotifier {
  final ClothRepositoryRemote _clothRepositoryRemote;
  late  Stream<Map<String, ClothModel>> _clothes;
  Map<String, ClothModel> _cachedClothes;
  bool _isLoading = false;
  String? _error;

  ClosetViewModel({
    required ClothRepositoryRemote clothRepositoryRemote,
  }) : _clothRepositoryRemote = clothRepositoryRemote,
  _cachedClothes = {},
  _isLoading = false,
  _error = null {
    _clothes = _clothRepositoryRemote.watchClothLocal();
  }

  Stream<Map<String, ClothModel>> get clothes => _clothes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, ClothModel> get cachedClothes => _cachedClothes;

  Future<void> fetchClothes() async {
  try {
    debugPrint("⭐ 1. fetchClothes 시작");
    _isLoading = true;
    notifyListeners();
    
    debugPrint("⭐ 2. Stream 접근 시도");
    final stream = _clothRepositoryRemote.watchClothLocal();
    
    debugPrint("⭐ 3. Stream.first 대기 시작");
    await stream.listen((data) {
      debugPrint("⭐ 4. 데이터 받음: ${data.length}개");
      data.forEach((key, cloth) {
        debugPrint("""
            🧥 Cloth[$key]:
              - id: ${cloth.id}
              - major: ${cloth.major}
              - minor: ${cloth.minor}
            """);
      });
      _cachedClothes = data;
      notifyListeners();
      _isLoading = false;
    }).asFuture();
  } catch (e) {
    debugPrint("❌ 에러 발생: $e");
    _error = e.toString();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
}