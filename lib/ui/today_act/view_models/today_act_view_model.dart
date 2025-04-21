import 'package:flutter/material.dart';
import 'package:weathercloset/data/repositories/memo/memo_repository_remote.dart';
import 'package:weathercloset/domain/models/memo/memo_model.dart';

class TodayActViewModel extends ChangeNotifier {
  final MemoRepositoryRemote _memoRepositoryRemote;
  late Stream<Map<String, MemoModel>> _memos;
  Map<String, MemoModel> _cachedMemos = {};
  Map<String, MemoModel> _todayMemos = {};
  bool _isLoading = false;
  String? _error;

  TodayActViewModel({
    required MemoRepositoryRemote memoRepositoryRemote,
  }) : _memoRepositoryRemote = memoRepositoryRemote,
       _isLoading = false,
       _error = null;

  Stream<Map<String, MemoModel>> get memos => _memos;
  Map<String, MemoModel> get cachedMemos => _cachedMemos;
  Map<String, MemoModel> get todayMemos => _todayMemos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // 오늘 생성된 메모의 수를 반환
  int get todayMemoCount => _todayMemos.length;

  void initCachedMemos() {
    _cachedMemos = _memoRepositoryRemote.getMemos();
    _filterTodayMemos();
    notifyListeners();
  }

  // 오늘 날짜의 메모만 필터링하는 메서드
  void _filterTodayMemos() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    _todayMemos = Map.fromEntries(
      _cachedMemos.entries.where((entry) {
        final memo = entry.value;
        final memoDate = DateTime(
          memo.createdAt.year, 
          memo.createdAt.month, 
          memo.createdAt.day
        );
        return memoDate.isAtSameMomentAs(today);
      })
    );
    
    debugPrint("✅ 오늘의 메모 개수: ${_todayMemos.length}");
  }

  Future<void> connectStreamToCachedMemos() async {
    try {
      debugPrint("⭐ 1. connectStreamToCachedMemos 시작");
      _isLoading = true;
      notifyListeners();
      
      debugPrint("⭐ 2. Stream 접근 시도");
      // _memos 필드에 스트림 할당
      _memos = _memoRepositoryRemote.watchMemoLocal();
      
      debugPrint("⭐ 3. Stream 구독 시작");
      _memos.listen((data) {
        debugPrint("⭐ 4. 데이터 받음: ${data.length}개");
        _cachedMemos = data;
        _filterTodayMemos();
        _isLoading = false;
        notifyListeners();
      });
      
      // 초기 데이터를 기다림
      _cachedMemos = await _memos.first;
      _filterTodayMemos();
      _isLoading = false;
      notifyListeners();
      
    } catch (e) {
      debugPrint("❌ 에러 발생: $e in [connectStreamToCachedMemos method] in [today_act_view_model]");
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void deleteMemo(String memoId) {
    _memoRepositoryRemote.deleteMemo(memoId);
    notifyListeners();
  }
  
  Future<void> updateMemo(MemoModel memo) async {
    try {
      // 로컬 캐시 업데이트
      _cachedMemos[memo.memoId] = memo;
      _filterTodayMemos(); // 오늘 메모 다시 필터링
      notifyListeners();
      
      // MemoRepository를 통해 Hive와 Firestore에 저장
      await _memoRepositoryRemote.updateMemo(memo);
      
      debugPrint("✅ 메모 업데이트 완료: ${memo.memoId}");
    } catch (e) {
      debugPrint("❌ 메모 업데이트 중 오류 발생: $e");
      _error = e.toString();
      notifyListeners();
    }
  }
}
