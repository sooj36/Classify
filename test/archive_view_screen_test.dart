import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:classify/ui/archive/archive_view/widgets/archive_view_screen.dart';
import 'package:classify/ui/archive/archive_view/view_models/archive_view_model.dart';
import 'package:classify/domain/models/memo/memo_model.dart';

// 간단한 Mock ViewModel 클래스
class MockArchiveViewModel extends ChangeNotifier implements ArchiveViewModel {
  @override
  Map<String, MemoModel> _cachedMemos = {};
  
  @override
  Map<String, MemoModel> get cachedMemos => _cachedMemos;
  
  set cachedMemos(Map<String, MemoModel> value) {
    _cachedMemos = value;
    notifyListeners();
  }
  
  @override
  String? _error;
  
  @override
  String? get error => _error;
  
  set error(String? value) {
    _error = value;
    notifyListeners();
  }
  
  @override
  bool _isLoading = false;
  
  @override
  bool get isLoading => _isLoading;
  
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  @override
  Future<void> connectStreamToCachedMemos() async {}
  
  @override
  void initCachedMemos() {}
  
  @override
  void deleteMemo(String memoId) {}
  
  @override
  Future<void> updateMemo(MemoModel memo) async {}
  
  @override
  Stream<Map<String, MemoModel>> get memos => Stream.value({});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockArchiveViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockArchiveViewModel();
  });

  testWidgets('ArchiveScreen shows loading indicator when isLoading is true', 
      (WidgetTester tester) async {
    // 로딩 상태 설정
    mockViewModel.isLoading = true;
    
    // 위젯 빌드
    await tester.pumpWidget(
      MaterialApp(
        home: ArchiveScreen(viewModel: mockViewModel),
      ),
    );
    
    // CircularProgressIndicator가 화면에 나타나는지 확인
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('ArchiveScreen shows error message when error is not null', 
      (WidgetTester tester) async {
    // 에러 상태 설정
    mockViewModel.isLoading = false;
    mockViewModel.error = '테스트 에러 메시지';
    
    // 위젯 빌드
    await tester.pumpWidget(
      MaterialApp(
        home: ArchiveScreen(viewModel: mockViewModel),
      ),
    );
    
    // 에러 메시지가 화면에 나타나는지 확인
    expect(find.text('에러 발생: 테스트 에러 메시지'), findsOneWidget);
  });

  testWidgets('ArchiveScreen shows empty message when there are no memos', 
      (WidgetTester tester) async {
    // 빈 데이터 상태 설정
    mockViewModel.isLoading = false;
    mockViewModel.error = null;
    mockViewModel.cachedMemos = {};
    
    // 위젯 빌드
    await tester.pumpWidget(
      MaterialApp(
        home: ArchiveScreen(viewModel: mockViewModel),
      ),
    );
    
    // 빈 메시지가 화면에 나타나는지 확인
    expect(find.text('메모장이 비어있습니다'), findsOneWidget);
  });

  testWidgets('ArchiveScreen shows TabBar with three categories', 
      (WidgetTester tester) async {
    // 데이터가 있는 상태 설정
    mockViewModel.isLoading = false;
    mockViewModel.error = null;
    mockViewModel.cachedMemos = {
      '1': MemoModel(
        memoId: '1',
        title: '테스트 메모',
        content: '내용',
        category: '할 일',
      ),
    };
    
    // 위젯 빌드
    await tester.pumpWidget(
      MaterialApp(
        home: ArchiveScreen(viewModel: mockViewModel),
      ),
    );
    
    // 탭바가 화면에 나타나는지 확인
    expect(find.byType(TabBar), findsOneWidget);
    
    // 세 가지 탭이 있는지 확인
    expect(find.text('할 일'), findsOneWidget);
    expect(find.text('공부'), findsOneWidget);
    expect(find.text('아이디어'), findsOneWidget);
  });
}
