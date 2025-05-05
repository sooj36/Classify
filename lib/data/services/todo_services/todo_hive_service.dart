import 'package:classify/domain/models/todo/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rxdart/transformers.dart';

class TodoHiveService {
  late Box<TodoModel> _todoBox;

  TodoHiveService() {
    _todoBox = Hive.box<TodoModel>("todo");
  }

  void saveTodo(TodoModel todoModel, String uuid) {
    _todoBox.put(uuid, todoModel);
  }

  void updateTodo(TodoModel todoModel, String uuid) {
    _todoBox.put(uuid, todoModel);
  }

  Map<dynamic, dynamic> getTodos() {
    return _todoBox.toMap();
  }

  // todo 목록, 실시간으로 조회
  Stream<Map<dynamic, dynamic>> watchTodos() {
    final todoHive = Hive.box<TodoModel>("todo");
    return todoHive
        .watch()
        .map((_) => todoHive.toMap())
        .startWith(todoHive.toMap());
  }

  void deleteTodo(String id) {
    _todoBox.delete(id);
  }

  void clearTodos() {
    _todoBox.clear();
    debugPrint("✅ 모든 hive Todo 삭제 완료");
  }

  Future<void> syncTodosFromServer(Map<String, TodoModel> todos) async {
    // 기존 TODO 데이터 지우기
    _todoBox.clear();

    // box 닫았다가 다시 열기(동기화 위해)
    await Hive.box<TodoModel>("todo").close();
    _todoBox = await Hive.openBox<TodoModel>("todo");

    // 한 번에 모든 todo 저장
    _todoBox.putAll(todos);
    debugPrint("✅ Todo 데이터 로컬 동기화 완료: ${todos.length}개");
  }
}
