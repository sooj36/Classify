import 'package:weathercloset/data/repositories/memo/memo_repository.dart';
import 'package:weathercloset/data/services/gemini_service.dart';
import 'package:weathercloset/data/services/firestore_service.dart';
import 'package:weathercloset/data/services/hive_service.dart';
import 'package:weathercloset/data/services/image_storage_service.dart';
import 'package:weathercloset/domain/models/memo/memo_model.dart';
import 'package:flutter/foundation.dart';

/*
  [기본 가이드]
  MemoRepository에서는 [데이터 변환이 빈번하게 발생]하므로 아래 개념을 정확히 이해해야 함:
   - Map: 키-값 쌍을 저장하는 자료구조
   - map(): 데이터를 변환하는 메서드(원본 데이터는 유지되고 새로운 컬렉션 반환)
   - Entry: Map의 각 키-값 쌍을 나타내는 단위
   예: map.entries.map((e) => ...) 
      => Map 자료구조의 각 Entry에 대해 map 메서드가 인자로 받는 변환 함수 적용
*/


class MemoRepositoryRemote extends MemoRepository {
  final GeminiService _geminiService;
  final FirestoreService _firestoreService;
  final HiveService _hiveService;
  final ImageStorageService _imageStorageService;
  List<String> _categories = [];

  MemoRepositoryRemote({
    required GeminiService geminiService,
    required FirestoreService firestoreService,
    required HiveService hiveService,
    required ImageStorageService imageStorageService,
  }) : _geminiService = geminiService,
       _firestoreService = firestoreService,
       _hiveService = hiveService,
       _imageStorageService = imageStorageService {
        _initCategories();
       }

  void _initCategories() {
    _categories = _hiveService.getCategories();
  }

  @override
  Future<void> analyzeAndSaveMemo(String memo) async {
    MemoModel analyzedMemo = await _geminiService.analyzeMemo(memo, _categories);
    debugPrint('🔍 분류된 메모: ${analyzedMemo.category}');
    debugPrint('🔍 분류된 메모: ${analyzedMemo.title}');
    debugPrint('🔍 분류된 메모: ${analyzedMemo.content}');

    // await _hiveService.saveMemo(analyzedMemo);
    // await _firestoreService.saveMemo(analyzedMemo);
  }

  @override
  Stream<Map<String, MemoModel>> watchMemoLocal() {
    return _hiveService
      .watchMemos()
      .map((map) {
        return Map.fromEntries(
          map.entries.map((e) {
            final memo = e.value as MemoModel; // Hive에서 가져온 value를 MemoModel로 캐스팅
            return MapEntry(
              e.key.toString(),
              memo.copyWith(),
            );
          }),
        );
      }).asBroadcastStream();
  }
} 