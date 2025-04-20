import 'package:hive/hive.dart';
import 'package:weathercloset/domain/models/memo/memo_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/foundation.dart';


class HiveService {
  late Box<MemoModel> _memoBox;
  late Box<List<String>> _categoryBox;
  HiveService() {
    _memoBox = Hive.box<MemoModel>("memo");
    _categoryBox = Hive.box<List<String>>("category");
  }

  void saveMemo(MemoModel memo, String uuid) {
    _memoBox.put(uuid, memo);
  }

  Map<dynamic, dynamic> getMemos() {
    return _memoBox.toMap();
  }

  // 메모 목록을 실시간으로 조회하는 용도
  // 로컬 데이터베이스에 변화가 생기면 자동으로 화면에 반영됨
  Stream<Map<dynamic, dynamic>> watchMemos() {
    final memo = Hive.box<MemoModel>("memo");
    return memo
        .watch()
        .map((_) => memo.toMap())
        .startWith(memo.toMap());
  }

  void createCategoryWhenSignup() {
    _categoryBox.put("categories", ["아이디어", "공부", "할 일", "업무", "스크랩"]);
  }

  List<String> getCategories() {
    return _categoryBox.get("categories") ?? [];
  }

  void deleteMemo(String id) {
    _memoBox.delete(id);
  }

  void clearMemos() {
    _memoBox.clear();
    debugPrint("✅ 메모 데이터 로컬 초기화 완료");
  }

  void clearCategories() {
    _categoryBox.clear();
    debugPrint("✅ 카테고리 데이터 로컬 초기화 완료");
  }

  Future<void> syncMemosFromServer(Map<String, MemoModel> memos) async {
    // 기존 메모 데이터 지우기
    _memoBox.clear();

      await Hive.box<MemoModel>("memo").close();

  // Box 다시 열기
      _memoBox = await Hive.openBox<MemoModel>("memo");
    
    // 한 번에 모든 메모 저장
    _memoBox.putAll(memos);
    
    // 로깅 목적으로 몇 개의 샘플 확인
    if (memos.isNotEmpty) {
      final sampleKey = memos.keys.first;
      debugPrint("🔄 샘플 메모 확인 - 키: $sampleKey, 제목: ${memos[sampleKey]?.title}");
    }
    
    debugPrint("✅ 메모 데이터 로컬 동기화 완료: ${memos.length}개");
  }

  Future<void> syncCategoriesFromServer(List<String> categories) async {
    if (categories.isNotEmpty) {
      await Hive.box<List<String>>("category").close();
      _categoryBox = await Hive.openBox<List<String>>("category");
      _categoryBox.put("categories", categories);
      debugPrint("✅ 카테고리 데이터 로컬 동기화 완료: ${categories.length}개");
    }
  }

  void showMemoBox() {
    final box = Hive.box<MemoModel>("memo");
    debugPrint("✅ memobox 조회, 항목 수: ${box.length}");
    
    // 모든 키 출력
    debugPrint("📝 모든 키: ${box.keys.toList()}");
    
    // 각 키에 해당하는 값 가져오기
    for (var key in box.keys) {
      final value = box.get(key);
      debugPrint("🔑 키: $key, 값: ${value?.title ?? '값 없음'}");
    }
  }
}