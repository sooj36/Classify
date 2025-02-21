import 'package:hive/hive.dart';
import '../../../domain/models/cloth/cloth_model.dart';
import 'package:rxdart/rxdart.dart';


class HiveService {
  late final Box<ClothModel> _box;

  // 생성자에서 box 초기화
  HiveService() {
    _box = Hive.box<ClothModel>("clothes");
  }

  void saveCloth(ClothModel cloth, String uuid) {
    _box.put(uuid, cloth);
  }

  Map<String, ClothModel> getCloths() {
    final map = _box.toMap();
    return map.map(
      (key, value) => MapEntry(key.toString(), value)
    );
  }

  Stream<Map<dynamic, dynamic>> watchCloths() {
    return _box
        .watch()
        .map((_) => _box.toMap())
        .startWith(_box.toMap());
  }

  void deleteCloth(String id) {
    _box.delete(id);
  }

  void clear() {
    _box.clear();
  }
}