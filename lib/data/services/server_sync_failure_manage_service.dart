import 'package:classify/domain/models/memo/memo_model.dart';
import 'package:flutter/material.dart';

class ServerSyncFailureManageService extends ChangeNotifier {
  final List<MemoModel> _failures = [];

  List<MemoModel> get failures => _failures;
  
  void addFailure(MemoModel memo) {
    _failures.add(memo);
    notifyListeners();
  }

  void removeFailure(MemoModel memo) {
    _failures.remove(memo);
    notifyListeners();
  }

  void clearFailures() {
    _failures.clear();
    notifyListeners();
  }
}
