import 'package:hive/hive.dart';
import 'package:weathercloset/domain/models/memo/memo_model.dart';
import 'package:rxdart/rxdart.dart';


class HiveService {
  late final Box<MemoModel> _memoBox;
  late final Box<List<String>> _categoryBox;
  HiveService() {
    _memoBox = Hive.box<MemoModel>("memo");
    _categoryBox = Hive.box<List<String>>("category");
  }

  void saveMemo(MemoModel memo, String uuid) {
    _memoBox.put(uuid, memo);
  }

  Map<String, MemoModel> getMemos() {
    final map = _memoBox.toMap();
    return map.map(
      (key, value) => MapEntry(key.toString(), value)
    );
  }

  // 메모 목록을 실시간으로 조회하는 용도
  // 로컬 데이터베이스에 변화가 생기면 자동으로 화면에 반영됨
  Stream<Map<dynamic, dynamic>> watchMemos() {
    return _memoBox
        .watch()
        .map((_) => _memoBox.toMap())
        .startWith(_memoBox.toMap());
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

  void clear() {
    _memoBox.clear();
  }
}