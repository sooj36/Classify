import 'package:hive/hive.dart';
import '../../../domain/models/cloth/cloth_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';

class HiveService {

  void saveCloth(ClothModel cloth, String uuid) {
    Box box = Hive.box("clothes");

    box.put(uuid, cloth);
  }

  Map<String, ClothModel> getCloths() {
    final map = Hive.box("clothes").toMap();
    return map.map(
      (key, value) => 
      MapEntry(key.toString(), value as ClothModel) //dynamic, dynamic을 타입 캐스팅
      );
  }

  Stream<Map<dynamic, dynamic>> watchCloths() {
  final box = Hive.box("clothes");
  return box
      .watch()
      .map((_) => box.toMap())
      .startWith(box.toMap());
}

  void deleteCloth(String id) {
    Hive.box("clothes").delete(id);
  }

  void clear() {
    Hive.box("clothes").clear();
  }
}