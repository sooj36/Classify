import 'dart:math';
import 'package:classify/data/repositories/todo/todo_repository.dart';
import 'package:classify/domain/models/todo/todo_model.dart';
import 'package:flutter/material.dart';

class TodoViewModel extends ChangeNotifier {
  final TodoRepository _todoRepository;
  late Stream<Map<String, TodoModel>> _todoModels;
  Map<String, TodoModel> _cachedTodoModels = {};
  bool _isLoading = false;
  String? _error;

  bool _isLatestSort = true;

  TodoViewModel({
    required TodoRepository todoRepository,
  })  : _todoRepository = todoRepository,
        _isLoading = false,
        _error = null;

  Stream<Map<String, TodoModel>> get todoModels => _todoModels;
  Map<String, TodoModel> get cachedTodoModels => _cachedTodoModels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void initCachedTodos() {
    _cachedTodoModels = _todoRepository.getTodos();
    notifyListeners();
  }

  Future<void> connectStreamToCachedTodos() async {
    try {
      debugPrint("⭐ 1. connectStreamToCachedTodos 시작 [todo_view_model]");
      _isLoading = true;
      notifyListeners();

      _todoModels = _todoRepository.watchTodoLocal();

      _todoModels.listen((data) {
        debugPrint("⭐ 데이터 받음: ${data.length}개 Todo");
        _cachedTodoModels = data;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint(
          "❌ 에러 발생: $e in [connectStreamToCachedTodos method] in [todo_view_model]");
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTodo(String content, {bool isImportant = false}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final String todoId = DateTime.now().microsecondsSinceEpoch.toString();

      final TodoModel newTodo = TodoModel(
        todoContent: content,
        isImportant: isImportant,
        todoId: todoId,
        createdAt: DateTime.now(),
      );

      await _todoRepository.createAndSaveTodo(newTodo);

      _cachedTodoModels[todoId] = newTodo;

      _isLoading = false;
      notifyListeners();

      debugPrint("✅ Todo 추가 완료: $todoId");
    } catch (e) {
      debugPrint("❌ Todo 추가 중 오류 발생: $e");
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void deleteTodo(String todoId) {
    // Stream을 통해 자동으로 업데이트되므로 별도로 notifyListeners 호출 불필요
    _todoRepository.deleteTodo(todoId);
  }

  void updateTodo(TodoModel todoModel) async {
    try {
      // 로컬 캐시 업데이트
      _cachedTodoModels[todoModel.todoId] = todoModel;
      notifyListeners();

      // Todo Repository 통해 Hive & Firebase에 저장
      await _todoRepository.updateTodo(todoModel);
      debugPrint("✅ 할일 업데이트 완료: ${todoModel.todoId}");
    } catch (e) {
      debugPrint("❌ 할일일 업데이트 중 오류 발생: $e");
      _error = e.toString();
      notifyListeners();
    }
  }

  // 변경
  Future<void> toggleCompleted(String todoId) async {
    try {
      // 해당 ID의 TODO 찾기
      final targetTodo = _cachedTodoModels[todoId];
      if (targetTodo != null) {
        // 완료 상태 반전
        final updatedTodo = targetTodo.copyWith(
          isDone: !(targetTodo.isDone ?? false),
          lastModified: DateTime.now(),
        );

        // 로컬 캐시 업데이트
        _cachedTodoModels[todoId] = updatedTodo;
        notifyListeners();

        // todo Repo 통해 저장
        await _todoRepository.updateTodo(updatedTodo);
        debugPrint("✅ Todo 완료 상태 변경: $todoId, 완료: ${updatedTodo.isDone}");
      }
    } catch (e) {
      debugPrint("❌ Todo 완료 상태 변경 중 오류 발생: $e");
      _error = e.toString();
      notifyListeners();
    }
  }

  //정렬 (최신순)
  void sortByLatest() {
    _isLatestSort = true;
    List<TodoModel> sortedList = _cachedTodoModels.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _cachedTodoModels = {for (var todo in sortedList) todo.todoId: todo};
    notifyListeners();
  }

  // 정렬 (오래된순)
  void sortByOldest() {
    _isLatestSort = false;
    // MAP 형태 데이터를 리스트로 변환하여 오름차순 정렬
    List<TodoModel> sortedList = _cachedTodoModels.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // 다시 MAP 생성
    _cachedTodoModels = {for (var todo in sortedList) todo.todoId: todo};
    notifyListeners();
  }

  // 완료된 항목만 필터링
  Map<String, TodoModel> filterByCompleted() {
    return Map.fromEntries(
        _cachedTodoModels.entries.where((entry) => entry.value.isDone == true));
  }

  // 미완료된 항목만 필터링
  Map<String, TodoModel> filterByIncomplete() {
    return Map.fromEntries(
        _cachedTodoModels.entries.where((entry) => entry.value.isDone != true));
  }

  // 모든 필터 초기화(필터 해제)
  Map<String, TodoModel> getAllTodos() {
    return _cachedTodoModels;
  }

  // 검색
  Map<String, TodoModel> searchTodos(String query) {
    if (query.isEmpty) {
      return _cachedTodoModels;
    }

    final lowercaseQuery = query.toLowerCase().trim(); // 소문자로 변환

    // 검색어가 포함된 Todo 항목만 필터링
    return Map.fromEntries(_cachedTodoModels.entries.where((entry) {
      final todoObject = entry.value;
      final content = todoObject.todoContent.toLowerCase();

      // 내용에 검색어가 포함되어 있는지 확인
      return content.contains(lowercaseQuery);
    }));
  }

  // 로딩 상태 설정
  void setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  // 오류 상태 설정
  void setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  // 오류 상태 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
