import 'package:flutter/material.dart';
import '../../../../data/repositories/cloth_analyze/cloth_repository_remote.dart';
import '../../../../domain/models/cloth/cloth_model.dart';

class ClosetViewModel extends ChangeNotifier {
  final ClothRepositoryRemote _clothRepositoryRemote;
  Stream<List<ClothModel>> _clothes;
  bool _isLoading;
  String? _error;

  ClosetViewModel({
    required ClothRepositoryRemote clothRepositoryRemote,
  }) : _clothRepositoryRemote = clothRepositoryRemote,
  _clothes = clothRepositoryRemote.watchCloth(), //얘를 처음에 초기화시켜 주지 않고 const empty로 초기화해서 문제생겼었음왜일까
  _isLoading = false,
  _error = null;

  Stream<List<ClothModel>> get clothes => _clothes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchClothes() async {
    try {
      debugPrint("✅ 옷 데이터 로드 시작!");
      _isLoading = true;
      _clothes = _clothRepositoryRemote.watchCloth(); //어라 이거 중복 아니야?
      _clothes.listen((cloth) {
        if (cloth.isEmpty) {
          debugPrint("❌ 옷 데이터 로드 실패!");
          _isLoading = false;
          notifyListeners();
          return;
        }
        debugPrint("✅ 옷 데이터 로드 성공! - closetviewmodel - ${cloth[0].major}");
        debugPrint("✅ 옷 데이터 로드 성공! - closetviewmodel - ${cloth[0].minor}");
        debugPrint("✅ 옷 데이터 로드 성공! - closetviewmodel - ${cloth[0].color}");
        debugPrint("✅ 옷 데이터 로드 성공! - closetviewmodel - ${cloth[0].material}");
      });
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  
}