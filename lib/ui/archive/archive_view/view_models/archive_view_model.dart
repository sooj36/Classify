import 'package:flutter/material.dart';
import 'package:weathercloset/data/repositories/memo/memo_repository.dart';
import 'package:weathercloset/domain/models/memo/memo_model.dart';


//StreamBuilder를 사용하지 않고 데이터를 캐시하여 사용하였음
//화면을 전환하면 Stream으로부터 새 데이터가 오기 전까지는 데이터를 표시하지 않기 때문
class ArchiveViewModel extends ChangeNotifier {
  final MemoRepository _memoRepository;
  late  Stream<Map<String, MemoModel>> _memos;
  Map<String, MemoModel> _cachedMemos = {};
  bool _isLoading = false;
  String? _error;

  ArchiveViewModel({
    required MemoRepository memoRepository,
  }) : _memoRepository = memoRepository,
  _isLoading = false,
  _error = null;

  Stream<Map<String, MemoModel>> get memos => _memos;
  Map<String, MemoModel> get cachedMemos => _cachedMemos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void initCachedMemos() {
    _cachedMemos = _memoRepository.getMemos();
    notifyListeners();
  }

  //1번만 이 함수가 실행되면 stream에 변화가 있을 때마다 listen함수가 자동으로 cachedmemo를 업데이트함.
  Future<void> connectStreamToCachedMemos() async {
    try {
      debugPrint("⭐ 1. connectStreamToCachedMemos 시작");
      _isLoading = true;
      notifyListeners();
      
      debugPrint("⭐ 2. Stream 접근 시도");
      // _memos 필드에 스트림 할당
      _memos = _memoRepository.watchMemoLocal();
      
      debugPrint("⭐ 3. Stream 구독 시작");
      _memos.listen((data) {
        debugPrint("⭐ 4. 데이터 받음: ${data.length}개");
        data.forEach((key, memo) {
          debugPrint("""
            📝 Memo[$key]:
              - title: ${memo.title}
              - content: ${memo.content}
            """);
        });
        _cachedMemos = data;
        _isLoading = false;
        notifyListeners();
      });
      
      // 초기 데이터를 기다림 (first는 listen과 별도로 작동함)
      _cachedMemos = await _memos.first;
      _isLoading = false;
      notifyListeners();
      
    } catch (e) {
      debugPrint("❌ 에러 발생: $e in [connectStreamToCachedMemos method] in [archive_view_model]");
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }


  void deleteMemo(String memoId) {
    _memoRepository.deleteMemo(memoId);
    notifyListeners();
  }
  
  Future<void> updateMemo(MemoModel memo) async {
    try {
      // 로컬 캐시 업데이트
      _cachedMemos[memo.memoId] = memo;
      notifyListeners();
      
      // MemoRepository를 통해 Hive와 Firestore에 저장
     await _memoRepository.updateMemo(memo);
      
      debugPrint("✅ 메모 업데이트 완료: ${memo.memoId}");
    } catch (e) {
      debugPrint("❌ 메모 업데이트 중 오류 발생: $e");
      _error = e.toString();
      notifyListeners();
    }
  }
}