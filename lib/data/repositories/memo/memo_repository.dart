import 'package:flutter/material.dart';
import 'package:weathercloset/domain/models/memo/memo_model.dart';

abstract class MemoRepository extends ChangeNotifier {

  Future<void> analyzeAndSaveMemo(String memo);

  Stream<Map<String, MemoModel>> watchMemoLocal();

  // Future<void> saveMemo(MemoModel memo);
} 