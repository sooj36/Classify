import 'package:flutter/material.dart';
import 'package:weathercloset/data/repositories/memo_analyze/memo_analyze_repository_remote.dart';

//StreamBuilder를 사용하지 않고 데이터를 캐시하여 사용하였음
//화면을 전환하면 Stream으로부터 새 데이터가 오기 전까지는 데이터를 표시하지 않기 때문
class SendMemoToAiViewModel extends ChangeNotifier {
  final MemoAnalyzeRepositoryRemote _memoAnalyzeRepositoryRemote;
  bool _isLoading;

  String? _error;

  SendMemoToAiViewModel({
    required MemoAnalyzeRepositoryRemote memoAnalyzeRepositoryRemote,
  }) : _memoAnalyzeRepositoryRemote = memoAnalyzeRepositoryRemote,
  _isLoading = false,
  _error = null;

  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> sendMemoToAi() async {
  }

}