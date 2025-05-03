import 'package:flutter/material.dart';
import 'package:classify/data/repositories/memo/memo_repository.dart';
import 'package:classify/domain/models/memo/memo_model.dart';


enum SearchFilter {
  all,
  title,
  tag
}

class SearchViewModel extends ChangeNotifier {
  final MemoRepository _memoRepository;
  Map<String, MemoModel> _allMemos = {};
  List<MemoModel> _searchResults = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;
  SearchFilter _searchFilter = SearchFilter.all;
  bool _isLatestSort = true; // true: 최신순, false: 오래된순

  SearchViewModel({required MemoRepository memoRepository}) 
    : _memoRepository = memoRepository;

  // Getters
  List<MemoModel> get searchResults => _searchResults;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  SearchFilter get searchFilter => _searchFilter;
  bool get isLatestSort => _isLatestSort;

  // 메모 데이터 로드
  Future<void> connectStreamToCachedMemos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint("메모 데이터 로드 시작");
      final stream = _memoRepository.watchMemoLocal();
      
      stream.listen((memos) {
        _allMemos = memos;
        debugPrint("메모 데이터 로드 완료: ${_allMemos.length}개");
        
        // 검색어가 있는 경우 결과 업데이트
        if (_searchQuery.isNotEmpty) {
          _performSearch();
        }
        
        _isLoading = false;
        notifyListeners();
      }).onError((e) {
        debugPrint("메모 데이터 로드 오류: $e");
        _error = "데이터를 불러오는 중 오류가 발생했습니다: $e";
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint("메모 데이터 로드 예외: $e");
      _error = "데이터를 불러오는 중 예외가 발생했습니다: $e";
      _isLoading = false;
      notifyListeners();
    }
  }

  // 필터 설정
  void setSearchFilter(SearchFilter filter) {
    _searchFilter = filter;
    _performSearch();
  }

  // 정렬 방식 설정 (최신순)
  void sortByLatest() {
    _isLatestSort = true;
    _sortResults();
  }

  // 정렬 방식 설정 (오래된순)
  void sortByOldest() {
    _isLatestSort = false;
    _sortResults();
  }

  // 검색 실행
  void search(String query) {
    _searchQuery = query;
    
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    
    _performSearch();
  }
  
  // 검색 지우기
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  // 검색 수행 내부 메서드
  void _performSearch() {
    debugPrint("검색 실행: '$_searchQuery' (필터: $_searchFilter)");
    
    if (_searchQuery.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    final lowerCaseQuery = _searchQuery.toLowerCase();
    
    // 필터에 따른 검색
    _searchResults = _allMemos.values.where((memo) {
      switch (_searchFilter) {
        // 제목과 태그 모두 검색
        case SearchFilter.all:
          final titleMatch = memo.title.toLowerCase().contains(lowerCaseQuery);
          bool tagMatch = false;
          if (memo.tags != null) {
            tagMatch = memo.tags!.any((tag) => tag.toLowerCase().contains(lowerCaseQuery));
          }
          return titleMatch || tagMatch;
          
        // 제목만 검색
        case SearchFilter.title:
          return memo.title.toLowerCase().contains(lowerCaseQuery);

        // 태그만 검색  
        case SearchFilter.tag:
          if (memo.tags != null) {
            return memo.tags!.any((tag) => tag.toLowerCase().contains(lowerCaseQuery));
          }
          return false;
      }
    }).toList();

    // 결과 정렬
    _sortResults();
  }
  
  // 결과 정렬 내부 메서드
  void _sortResults() {
    if (_isLatestSort) {
      // 최신순 정렬
      _searchResults.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      // 오래된순 정렬
      _searchResults.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }    
    notifyListeners();
  }

  // 메모 삭제
  void deleteMemo(String memoId, String category) {
    _memoRepository.deleteMemo(memoId, category);
  }
}
