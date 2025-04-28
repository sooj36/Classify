import 'package:flutter/material.dart';
import 'package:classify/data/repositories/memo/memo_repository.dart';
import 'package:classify/domain/models/memo/memo_model.dart';
import 'dart:math';

class StudyViewModel extends ChangeNotifier {
  final MemoRepository _memoRepository;
  late Stream<Map<String, MemoModel>> _memos;
  Map<String, MemoModel> _cachedMemos = {};
  List<MemoModel> _randomStudyMemos = [];
  bool _isLoading = false;
  String? _error;

  StudyViewModel({
    required MemoRepository memoRepository,
  }) : _memoRepository = memoRepository,
       _isLoading = false,
       _error = null;

  Stream<Map<String, MemoModel>> get memos => _memos;
  Map<String, MemoModel> get cachedMemos => _cachedMemos;
  List<MemoModel> get randomStudyMemos => _randomStudyMemos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void initCachedMemos() {
    _cachedMemos = _memoRepository.getMemos();
    _generateRandomStudyMemos();
    notifyListeners();
  }

  // 스트림 연결 - 메모 변경 시 자동 업데이트
  Future<void> connectStreamToCachedMemos() async {
    try {
      debugPrint("⭐ 1. connectStreamToCachedMemos 시작 [study_view_model]");
      _isLoading = true;
      notifyListeners();
      
      debugPrint("⭐ 2. Stream 접근 시도");
      // _memos 필드에 스트림 할당
      _memos = _memoRepository.watchMemoLocal();
      
      debugPrint("⭐ 3. Stream 구독 시작");
      _memos.listen((data) {
        debugPrint("⭐ 4. 데이터 받음: ${data.length}개");
        _cachedMemos = data;
        _generateRandomStudyMemos();
        _isLoading = false;
        notifyListeners();
      });
      
      // 초기 데이터를 기다림
      _cachedMemos = await _memos.first;
      _generateRandomStudyMemos();
      _isLoading = false;
      notifyListeners();
      
    } catch (e) {
      debugPrint("❌ 에러 발생: $e in [connectStreamToCachedMemos method] in [study_view_model]");
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 랜덤 스터디 메모 생성
  void _generateRandomStudyMemos({int count = 5}) {
    // 공부 카테고리의 메모 중 질문이 있는 메모만 필터링
    final studyMemos = _cachedMemos.values.where((memo) => 
      memo.category == '공부' && 
      memo.question != null && 
      memo.question!.isNotEmpty
    ).toList();
    
    if (studyMemos.isEmpty) {
      _randomStudyMemos = [];
      return;
    }
    
    // 랜덤으로 count개 선택
    _randomStudyMemos = _getRandomMemos(studyMemos, count);
    debugPrint("✅ 랜덤 스터디 메모 ${_randomStudyMemos.length}개 생성 완료");
  }

  // 새로운 랜덤 메모 세트 생성
  void refreshRandomStudyMemos({int count = 5}) {
    _generateRandomStudyMemos(count: count);
    notifyListeners();
  }

  // 메모 삭제
  void deleteMemo(String memoId) {
    _memoRepository.deleteMemo(memoId);
    // Stream을 통해 자동으로 업데이트되므로 별도로 notifyListeners 호출 불필요
  }
  
  // 메모 업데이트
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
  
  // 랜덤 메모를 가져오는 함수
  List<MemoModel> _getRandomMemos(List<MemoModel> memos, int count) {
    final random = Random();
    final result = <MemoModel>[];
    
    // 메모 리스트가 요청 개수보다 작으면 전체 리스트 반환
    if (memos.length <= count) {
      return memos;
    }
    
    // 비복원 추출을 이용하여 중복 없이 랜덤하게 메모 선택
    final tempList = List<MemoModel>.from(memos);
    for (int i = 0; i < count; i++) {
      final randomIndex = random.nextInt(tempList.length);
      result.add(tempList[randomIndex]);
      tempList.removeAt(randomIndex);
    }
    
    return result; 
  }
} 