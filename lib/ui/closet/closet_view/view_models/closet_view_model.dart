import 'package:flutter/material.dart';
import '../../../../data/repositories/cloth_analyze/cloth_repository_remote.dart';
import '../../../../domain/models/cloth/cloth_model.dart';

// class ClosetViewModel extends ChangeNotifier {
//   final ClothRepositoryRemote _clothRepositoryRemote;
//   Stream<Map<String, ClothModel>> _clothes;
//   bool _isLoading;
//   String? _error;

//   ClosetViewModel({
//     required ClothRepositoryRemote clothRepositoryRemote,
//   }) : _clothRepositoryRemote = clothRepositoryRemote,
//   _clothes = clothRepositoryRemote.watchClothLocal(), //얘를 처음에 초기화시켜 주지 않고 const empty로 초기화해서 문제생겼었음왜일까
//   _isLoading = false,
//   _error = null;

//   Stream<Map<String, ClothModel>> get clothes => _clothes;
//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   Future<void> fetchClothes() async {
//     try {
//       debugPrint("✅ 옷 데이터 로드 시작!");
//       _isLoading = true;
//       _clothes = _clothRepositoryRemote.watchClothLocal();
//       final firstData = await (await _clothes.first).isEmpty;
//       if (firstData) {
//         debugPrint("❌ 옷 데이터 로드 실패!");
//         _isLoading = false;
//         notifyListeners();
//         return;
//       }
//       _clothes.listen((cloth) {
//         if (cloth.isEmpty) {
//           debugPrint("❌ 옷 데이터 로드 실패!");
//           _isLoading = false;
//           notifyListeners();
//           return;
//         }
//         debugPrint("✅ 옷 데이터 로드 성공! - closetviewmodel");
//       });
//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }

class ClosetViewModel extends ChangeNotifier {
  final ClothRepositoryRemote _clothRepositoryRemote;
  late final Stream<Map<String, ClothModel>> _clothes;
  bool _isLoading = false;
  String? _error;

  ClosetViewModel({
    required ClothRepositoryRemote clothRepositoryRemote,
  }) : _clothRepositoryRemote = clothRepositoryRemote {
    _clothes = _clothRepositoryRemote.watchClothLocal();
  }

  Stream<Map<String, ClothModel>> get clothes => _clothes;
  bool get isLoading => _isLoading;
  String? get error => _error;

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