import 'package:flutter/material.dart';
import 'package:classify/domain/models/todo/todo_model.dart';

abstract class TodoRepository extends ChangeNotifier {
  Future<String?> createAndSaveTodo(TodoModel todo);
  
  Stream<Map<String, TodoModel>> watchTodoLocal();
  
  Future<void> deleteTodo(String todoId);
  
  Future<void> updateTodo(TodoModel todo);
  
  Map<String, TodoModel> getTodos();
  
  Future<void> syncFromServer();
}
