import 'package:classify/data/repositories/todo/todo_repository.dart';
import 'package:classify/domain/models/memo/memo_model.dart';
import 'package:classify/domain/models/todo/todo_model.dart';
import 'package:flutter/material.dart';

class TodoArchiveViewModel extends ChangeNotifier {
  final TodoRepository _todoRepository;
  late Stream<Map<String, TodoModel>> _todos;
  Map<String, TodoModel> _cachedTodos = {};
  bool _isLoading = false;
  String? _error;

  TodoArchiveViewModel({
    required TodoRepository todoRepository,
  })  : _todoRepository = todoRepository,
        _isLoading = false,
        _error = null;

  Stream<Map<String, TodoModel>> get todos => _todos;
  Map<String, TodoModel> get cachedTodos => _cachedTodos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void initCachedTodos() {
    _cachedTodos = _todoRepository.getTodos();
    notifyListeners();
  }

  Future<void> connectStreamToCachedTodos() async {
    try {
      debugPrint("💫 1. connectStreamToCachedTodos 시작💫");
      _isLoading = true;
      notifyListeners();

      debugPrint("💫 2. Stream 접근 시도💫");
      // _todos 필드에 스트림 할당
      _todos = _todoRepository.watchTodoLocal();

      debugPrint("💫 3. Stream 구독 시작💫");
      _todos.listen((data) {
        debugPrint("💫 4. 데이터 받음: ${data.length}개💫");
        data.forEach((key, todo) {
          debugPrint("""
            📝 Todo[$key]:
              - title: ${todo.title}
              - content: ${todo.content}
""");
        });
        _cachedTodos = data;
        _isLoading = false;
        notifyListeners();
      });

      // 초기 데이터를 기다림( first 는 listen과 별도로 작동)
      _cachedTodos = await _todos.first;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint(
          "❌ 에러 발생: $e in [connectStreamToCachedTodos method] in [todo_archive_view_model]");
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void deleteTodo(String todoId) {
    _todoRepository.deleteTodo(todoId);
    notifyListeners();
  }

  Future<void> updateTodo(TodoModel todo) async {
    try {
      // 로컬 캐시 업데이트
      _cachedTodos[todo.todoId];
      notifyListeners();

      // Todo Repository 통해 HIVE & FIREBASE 저장
      await _todoRepository.updateTodo(todo);
    } catch (e) {
      debugPrint("❌ 할일 업데이트 중 오류 발생: $e");
      _error = e.toString();
      notifyListeners();
    }
  }
}
