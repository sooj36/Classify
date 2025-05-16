import 'dart:async';
import 'dart:math';
import 'package:classify/data/repositories/todo/todo_repository.dart';
import 'package:classify/domain/models/todo/todo_model.dart';
import 'package:flutter/material.dart';

class TodoViewModel extends ChangeNotifier {
  final TodoRepository _todoRepository;
  late Stream<Map<String, TodoModel>> _todoObjects;
  Map<String, TodoModel> _cachedTodos = {};
  bool _isLoading = false;
  String? _error;
  Timer? _cleanupTimer;

  TodoViewModel({required TodoRepository todoRepository})
      : _todoRepository = todoRepository,
        _isLoading = false,
        _error = null;

// getter
  Stream<Map<String, TodoModel>> get todoObjects => _todoObjects;
  Map<String, TodoModel> get cachedTodos => _cachedTodos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void initCachedTodos() {
    _cachedTodos = _todoRepository.getTodos();
    notifyListeners();
  }

  Future<void> connectStreamToCachedTodos() async {
    try {
      //
      _isLoading = true;
      notifyListeners();

      // todo에 스트림 할당
      _todoObjects = _todoRepository.watchTodoLocal();

      _todoObjects.listen((data) {
        data.forEach((key, todo) {
          debugPrint("""
            📝 Todo[$key]:
              - content: ${todo.todoContent}
""");
        });
        _cachedTodos = data;
        _isLoading = false;
        notifyListeners();
      });

      // 초기 데이터 기다림 (first는 listen과 별도로 작동)
      _cachedTodos = await _todoObjects.first;
      _isLoading = false;
      notifyListeners();

      // 자동 정리 기능
      startAutoCleanup();
    } catch (e) {
      debugPrint(
          "❌ 에러 발생: $e in [connectStreamToCachedTodos method] in [todo_archive_view_model]");
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 새로운 할 일 생성 메서드
  Future<void> createTodo(String content,
      {bool isImportant = false, bool isVeryImportant = false}) async {
    try {
      if (content.trim().isEmpty) {
        _error = "할 일 내용을 입력해주세요";
        notifyListeners();
        return;
      }

      final newTodo = TodoModel(
          todoContent: content,
          todoId: '',
          isDone: false,
          isImportant: isImportant,
          isveryImportant: isVeryImportant,
          createdAt: DateTime.now(),
          lastModified: DateTime.now());

      final result = await _todoRepository.createAndSaveTodo(newTodo);

      if (result != null) {
        _error = result;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void toggleTodoStatus(String todoId) {
    final todo = cachedTodos[todoId];
    if (todo != null) {
      final bool isDone = todo.isDone ?? false; // null 체크
      final updatedTodo = todo.copyWith(isDone: !isDone);
      updateTodo(updatedTodo);
    }
  }

  void deleteTodo(String todoId) {
    _todoRepository.deleteTodo(todoId);
    notifyListeners();
  }

  Future<void> updateTodo(TodoModel todoModel) async {
    try {
      // 로컬 캐시 업데이트
      _cachedTodos[todoModel.todoId] = todoModel;
      // 저장소 업데이트
      await _todoRepository.updateTodo(todoModel);
      notifyListeners();
    } catch (e) {
      debugPrint("❌ 할일 업데이트 중 오류 발생: $e");
      _error = e.toString();
      notifyListeners();
    }
  }

  // 24시간 뒤 자동 삭제
  void cleanupOldDoneTodos() {
    final now = DateTime.now();
    final todosToDelete = <String>[];

    _cachedTodos.forEach((todoId, todo) {
      if (todo.isDone == true) {
        final completedTime = todo.lastModified ?? todo.createdAt;
        final difference = now.difference(completedTime);

        // 1분이 지났는지 확인 (테스트용)
        if (difference.inHours >= 1) {
          todosToDelete.add(todoId);
          debugPrint(
              '⏰ 삭제 예정 항목: ${todo.todoContent} (완료 후 ${difference.inHours}분 경과)');
        }
      }
    });

    // 삭제 대상 할 일들 처리
    for (final todoId in todosToDelete) {
      deleteTodo(todoId);
    }

    if (todosToDelete.isNotEmpty) {
      debugPrint('🗑️ ${todosToDelete.length}개의 오래된 완료 항목이 삭제되었습니다.');
    }
  }

  void startAutoCleanup() {
    cleanupOldDoneTodos();

    // 1시간마다 정리 작업 실행 (너무 자주 실행하면 리소스 낭비)
    _cleanupTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      cleanupOldDoneTodos();
    });
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    super.dispose();
  }
}
