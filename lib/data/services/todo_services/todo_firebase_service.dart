import 'package:classify/domain/models/todo/todo_model.dart';
import 'package:classify/global/global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TodoFirebaseService {
  late FirebaseFirestore _firestore;

  TodoFirebaseService() {
    _firestore = FirebaseFirestore.instance;

    _firestore.settings = const Settings(
      persistenceEnabled: true,
      webExperimentalAutoDetectLongPolling: true,
    );

    _firestore.enableNetwork().then((_) {
      debugPrint("✅ TODO_Firestore network enabled");
    }).catchError((error) {
      debugPrint(
          "❌ Failed to enable network: $error in [todo_firestore_service]");
    });

    if (firebaseAuth.currentUser == null) {
      debugPrint("❌ No authenticated user! in [todo_firestore_service]");
    } else {
      debugPrint("✅ User is authenticated: ${firebaseAuth.currentUser!.uid}");
    }
  }

  Future<void> saveTodo(TodoModel todoModel, String uuid) async {
    await _firestore
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .collection("todo")
        .doc(uuid)
        .set({
      'todoContent': todoModel.todoContent,
      'isImportant': todoModel.isImportant,
      'lastModified': todoModel.lastModified,
      'createdAt': todoModel.createdAt,
      'isDone': todoModel.isDone,
      'todoId': todoModel.todoId,
    });
  }

  // 업데이트
  Future<void> updateTodo(TodoModel todoModel, String uuid) async {
    await _firestore
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .collection("todo")
        .doc(uuid)
        .set({
      'todoContent': todoModel.todoContent,
      'isImportant': todoModel.isImportant,
      'lastModified': DateTime.now(), // 항상 현재 시간으로 업데이트
      'createdAt': todoModel.createdAt,
      'isDone': todoModel.isDone,
      'todoId': todoModel.todoId,
    });
    debugPrint("✅ Todo 업데이트 완료: $uuid");
  }

  Stream<QuerySnapshot> watchTodo() {
    return _firestore
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .collection("todo")
        .snapshots();
  }

  Future<void> deleteTodo(String todoId) async {
    await _firestore
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .collection("todo")
        .doc(todoId)
        .delete();
  }

  Future<Map<String, TodoModel>> getUserTodos() async {
    try {
      final querySnapshot = await _firestore
          .collection("users")
          .doc(firebaseAuth.currentUser!.uid)
          .collection("todo")
          .get();

      Map<String, TodoModel> todos = {};
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        todos[doc.id] = TodoModel(
          todoContent: data['todoContent'] ?? '',
          isImportant: data['isImportant'] ?? false,
          lastModified: data['lastModified'] is Timestamp
              ? (data['lastModified'] as Timestamp).toDate()
              : data['lastModified'],
          createdAt: data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
          isDone: data['isDone'] ?? false,
          todoId: data['todoId'] ?? '',
        );
      }
      debugPrint("✅ Todo 데이터 가져오기 성공: ${todos.length}개");
      return todos;
    } catch (e) {
      debugPrint("❌ Todo 가져오기 실패: $e");
      return {};
    }
  }
}
