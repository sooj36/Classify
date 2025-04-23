import 'package:flutter/material.dart';
import 'package:weathercloset/data/repositories/memo/memo_repository_remote.dart';
import 'package:weathercloset/data/repositories/memo/memo_repository.dart';

//StreamBuilder를 사용하지 않고 데이터를 캐시하여 사용하였음
//화면을 전환하면 Stream으로부터 새 데이터가 오기 전까지는 데이터를 표시하지 않기 때문
class SendMemoToAiViewModel extends ChangeNotifier {
  final MemoRepository _memoRepository;
  bool _isLoading;

  String? _error;

  SendMemoToAiViewModel({
    required MemoRepository memoRepository,
  }) : _memoRepository = memoRepository,
  _isLoading = false,
  _error = null;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> sendMemoToAi(String memo) async {
    _isLoading = true;
    notifyListeners();
    final result = await _memoRepository.analyzeAndSaveMemo(memo);
    if (result != null) {
      _error = result;
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

}