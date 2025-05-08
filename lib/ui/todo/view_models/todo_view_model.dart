import 'dart:math';
import 'package:classify/data/repositories/todo/todo_repository.dart';
import 'package:classify/domain/models/todo/todo_model.dart';
import 'package:flutter/material.dart';

class TodoViewModel extends ChangeNotifier {
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
