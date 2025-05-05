import 'package:classify/data/repositories/todo/todo_repository.dart';
import 'package:classify/data/services/firestore_service.dart';
import 'package:classify/data/services/hive_service.dart';
import 'package:classify/data/services/todo_services/todo_firebase_service.dart';
import 'package:classify/data/services/todo_services/todo_hive_service.dart';
import 'package:classify/domain/models/todo/todo_model.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/*
  [기본 가이드]
  TodoRepository에서는 [데이터 변환이 빈번하게 발생]하므로 아래 개념을 정확히 이해해야 함:
  - Map: 키-값 쌍을 저장하는 자료구조
  - map(): 데이터를 변환하는 메서드(원본 데이터는 유지되고 새로운 컬렉션 반환)
  - Entry: Map의 각 키-값 쌍을 나타내는 단위
  예: map.entries.map((e) => ...) 
      => Map 자료구조의 각 Entry에 대해 map 메서드가 인자로 받는 변환 함수 적용
*/

class TodoRepositoryRemote extends TodoRepository {
  final TodoFirebaseService _todoFirestoreService;
  final TodoHiveService _hiveService;

  TodoRepositoryRemote({
    required FirestoreService firestoreService,
    required TodoHiveService hiveService,
  })  : _todoFirestoreService = TodoFirebaseService(),
        _hiveService = hiveService;

  @override
  Future<String?> createAndSaveTodo(TodoModel todoId) async {
    try {
      // UUID 생성
      String uuid = const Uuid().v4();
      // 새로운 TodoModel 생성 (memoId가 없는 경우를 대비)
      final newTodo =
          todoId.todoId.isEmpty ? todoId.copyWith(todo: uuid) : todoId;

      // Hive에 저장
      _hiveService.saveTodo(newTodo, uuid);
      debugPrint('✅ 하이브 Todo 저장 완료');

      // Firestore에 저장
      await _todoFirestoreService.saveTodo(newTodo, uuid);
      debugPrint('✅ 파이어스토어 Todo 저장 완료');

      return null;
    } catch (e) {
      debugPrint(
          '❌ Todo 저장 중 오류 in [createAndSaveTodo method] in [todo_repository_remote]: $e');
      return e.toString();
    }
  }

  @override
  Stream<Map<String, TodoModel>> watchTodoLocal() {
    return _hiveService.watchTodos().map((map) {
      return Map.fromEntries(
        map.entries.map((e) {
          final todo = e.value as TodoModel; // Hive에서 가져온 value를 TodoModel로 캐스팅
          return MapEntry(
            e.key.toString(),
            todo.copyWith(),
          );
        }),
      );
    }).asBroadcastStream();
  }

  @override
  Future<void> deleteTodo(String todoId) async {
    try {
      await _todoFirestoreService.deleteTodo(todoId);
      _hiveService.deleteTodo(todoId);
      debugPrint('✅ Todo 삭제 완료');
    } catch (e) {
      debugPrint(
          '❌ Todo 삭제 실패 in [deleteTodo method] in [todo_repository_remote]: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateTodo(TodoModel todo) async {
    try {
      // lastModified 업데이트
      final updatedTodo = todo.copyWith(lastModified: DateTime.now());

      // Hive에 저장
      _hiveService.updateTodo(updatedTodo, todo.todoId);
      debugPrint('✅ 하이브 Todo 업데이트 완료');

      // Firestore에 저장
      await _todoFirestoreService.updateTodo(updatedTodo, todo.todoId);
      debugPrint('✅ 파이어스토어 Todo 업데이트 완료');
    } catch (e) {
      debugPrint(
          '❌ Todo 업데이트 실패 in [updateTodo method] in [todo_repository_remote]: $e');
      rethrow; // 에러를 상위로 전달
    }
  }

  @override
  Map<String, TodoModel> getTodos() {
    final rawTodos = _hiveService.getTodos();
    return rawTodos
        .map((key, value) => MapEntry(key.toString(), value as TodoModel));
  }

  @override
  Future<void> syncFromServer() async {
    try {
      // Firestore에서 Todo 데이터 가져오기
      final todos = await _todoFirestoreService.getUserTodos();

      // Hive에 데이터 동기화
      _hiveService.syncTodosFromServer(todos);
      debugPrint('✅ Todo 데이터 서버에서 동기화 완료');
    } catch (e) {
      debugPrint(
          '❌ Todo 서버에서 동기화 실패 in [syncFromServer method] in [todo_repository_remote]: $e');
      rethrow;
    }
  }
}
