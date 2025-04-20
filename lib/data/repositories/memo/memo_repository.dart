import 'package:flutter/material.dart';
import 'package:weathercloset/domain/models/memo/memo_model.dart';

abstract class MemoRepository extends ChangeNotifier {

  Future<String?> analyzeAndSaveMemo(String memo);

  Stream<Map<String, MemoModel>> watchMemoLocal();

  Future<void> deleteMemo(String memoId);
  
  Future<void> updateMemo(MemoModel memo);

  Map<String, MemoModel> getMemos();

  Future<void> syncFromServer();
} 