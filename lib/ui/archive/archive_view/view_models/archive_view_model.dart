import 'package:flutter/material.dart';
import 'package:weathercloset/data/repositories/memo/memo_repository_remote.dart';
import 'package:weathercloset/domain/models/memo/memo_model.dart';


//StreamBuilder를 사용하지 않고 데이터를 캐시하여 사용하였음
//화면을 전환하면 Stream으로부터 새 데이터가 오기 전까지는 데이터를 표시하지 않기 때문
class ArchiveViewModel extends ChangeNotifier {
  final MemoRepositoryRemote _memoRepositoryRemote;
  late  Stream<Map<String, MemoModel>> _memos;
  Map<String, MemoModel> _cachedMemos = {};
  bool _isLoading = false;
  String? _error;

  ArchiveViewModel({
    required MemoRepositoryRemote memoRepositoryRemote,
  }) : _memoRepositoryRemote = memoRepositoryRemote,
  _isLoading = false,
  _error = null;

  Stream<Map<String, MemoModel>> get memos => _memos;
  Map<String, MemoModel> get cachedMemos => _cachedMemos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  
  //1번만 이 함수가 실행되면 stream에 변화가 있을 때마다 listen함수가 자동으로 cachedmemo를 업데이트함.
  Future<void> fetchMemos() async {
    try {
      debugPrint("⭐ 1. fetchMemos 시작");
      _isLoading = true;
      notifyListeners();
      
      debugPrint("⭐ 2. Stream 접근 시도");
      final stream = _memoRepositoryRemote.watchMemoLocal();
      
      debugPrint("⭐ 3. Stream.first 대기 시작");
      await stream.listen((data) {
        debugPrint("⭐ 4. 데이터 받음: ${data.length}개");
        data.forEach((key, memo) {
          debugPrint("""
            📝 Memo[$key]:
              - title: ${memo.title}
              - content: ${memo.content}
            """);
        });
        _cachedMemos = data;
        notifyListeners();
        _isLoading = false;
      }).asFuture();
    } catch (e) {
      debugPrint("❌ 에러 발생: $e in [fetchMemos method] in [archive_view_model]");
      _error = e.toString();
    } finally {
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