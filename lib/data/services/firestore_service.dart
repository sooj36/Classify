import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:classify/domain/models/auth/signup_user_model.dart';
import 'package:classify/global/global.dart';
import 'package:flutter/foundation.dart';
import 'package:classify/domain/models/memo/memo_model.dart';
// import 'package:classify/domain/models/todo/todo_model.dart';

class FirestoreService {
  late FirebaseFirestore _firestore;

  FirestoreService() {
    _firestore = FirebaseFirestore.instance;

    _firestore.settings = const Settings(
      persistenceEnabled: true,
      webExperimentalForceLongPolling: true,
    );

    _firestore.enableNetwork().then((_) {
      debugPrint("✅ Firestore network enabled");
    }).catchError((error) {
      debugPrint("❌ Failed to enable network: $error in [firestore_service]");
    });

    if (firebaseAuth.currentUser == null) {
      debugPrint("❌ No authenticated user! in [firestore_service]");
    } else {
      debugPrint("✅ User is authenticated: ${firebaseAuth.currentUser!.uid}");
    }
  }

  Future<void> createUser({required UserModel user}) async {
    await _firestore.collection("users").doc(user.uid).set({
      "userUID": user.uid,
      "userEmail": user.email,
      "userName": user.name,
      "phone": user.phone,
      "status": user.status,
    });
  }

  Future<void> deleteUser() async {
    String uid = firebaseAuth.currentUser!.uid;

    try {
      // 1. 알려진 모든 하위 컬렉션 목록
      List<String> subCollections = ["memo", "categories"]; // 필요 시 컬렉션 추가

      // 2. 모든 하위 컬렉션의 문서 삭제
      for (String collection in subCollections) {
        final querySnapshot = await _firestore
            .collection("users")
            .doc(uid)
            .collection(collection)
            .get();

        //WriteBatch - 여러 문서에 대한 쓰기 작업을 원자적 작업으로 처리
        WriteBatch batch = _firestore.batch();
        for (var doc in querySnapshot.docs) {
          //삭제 작업을 batch에 추가
          batch.delete(doc.reference);
        }

        if (querySnapshot.docs.isNotEmpty) {
          //batch에 작업이 있으면 작업 실행
          await batch.commit();
        }
      }

      // 3. 최종적으로 사용자 문서 삭제
      await _firestore.collection("users").doc(uid).delete();

      debugPrint("✅ 사용자 데이터 삭제 완료");
    } catch (e) {
      debugPrint("❌ 사용자 데이터 삭제 실패: $e");
      rethrow;
    }
  }

  // 이미지 저장 기능이 아까워 일단은 살려놓았음
  // Future<void> saveCloth(Map<String, dynamic> cloth, XFile file, String uuid) async {
  //   final localFile = File(file.path);
  //   // Check if the file exists
  //   if (!await localFile.exists()) {
  //     debugPrint("❌ File not found at: ${file.path} in [saveCloth method] in [firestore_service]");
  //     throw Exception("File not found");
  //   }

  //   // Create metadata for the file
  //   final metadata = SettableMetadata(contentType: "image/jpeg");

  //   // Generate a unique storage path
  //   final storagePath = "cloth_images/${DateTime.now().millisecondsSinceEpoch}.jpg";
  //   final storageRef = FirebaseStorage.instance.ref().child(storagePath);

  //   // Start the upload task
  //   final uploadTask = storageRef.putFile(localFile, metadata);

  //   // Listen for state changes using snapshotEvents
  //   uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
  //     switch (snapshot.state) {
  //       case TaskState.running:
  //         final progress = 100.0 * (snapshot.bytesTransferred / snapshot.totalBytes);
  //         debugPrint("Upload is ${progress.toStringAsFixed(2)}% complete.");
  //         break;
  //       case TaskState.paused:
  //         debugPrint("Upload is paused.");
  //         break;
  //       case TaskState.canceled:
  //         debugPrint("Upload was canceled.");
  //         break;
  //       case TaskState.error:
  //         debugPrint("Upload encountered an error.");
  //         break;
  //       case TaskState.success:
  //         debugPrint("Upload succeeded.");
  //         break;
  //     }
  //   });

  //   // Await for the upload task to complete
  //   final snapshot = await uploadTask;
  //   if (snapshot.state == TaskState.success) {
  //     final downloadUrl = await snapshot.ref.getDownloadURL();
  //     cloth["imagePath"] = downloadUrl;

  //     await _firestore
  //       .collection("users")
  //       .doc(firebaseAuth.currentUser!.uid)
  //       .collection("cloths")
  //       .doc(uuid)
  //       .set(cloth);
  //     debugPrint("✅ Cloth saved successfully!");
  //   } else {
  //     debugPrint("❌ Upload failed with state: ${snapshot.state} in [saveCloth method] in [firestore_service]");
  //     throw Exception("Upload failed");
  //   }
  // }

  Future<void> saveMemo(MemoModel memo, String uuid) async {
    await _firestore
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .collection("memo")
        .doc(uuid)
        .set({
      'title': memo.title,
      'content': memo.content,
      'category': memo.category,
      'question': memo.question,
      'isImportant': memo.isImportant,
      'tags': memo.tags,
      'lastModified': memo.lastModified,
      'createdAt': memo.createdAt,
    });
  }

  // updateMemo 메서드 추가
  Future<void> updateMemo(MemoModel memo, String uuid) async {
    // 업데이트 시간 기록
    await _firestore
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .collection("memo")
        .doc(uuid)
        .set({
      'title': memo.title,
      'content': memo.content,
      'category': memo.category,
      'question': memo.question,
      'isImportant': memo.isImportant,
      'tags': memo.tags,
      'lastModified': DateTime.now(), // 항상 현재 시간으로 업데이트
      'createdAt': memo.createdAt,
    });
    debugPrint("✅ 메모 업데이트 완료: $uuid");
  }

  Stream<QuerySnapshot> watchMemo() {
    return _firestore
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .collection("memo")
        .snapshots();
  }

  Future<void> deleteMemo(String memoId) async {
    await _firestore
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .collection("memo")
        .doc(memoId)
        .delete();
  }

  Future<void> createCategoryWhenSignup() async {
    await _firestore
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .collection("categories")
        .add({
      "categories": ["공부", "아이디어", "참조", "회고"],
    });
  }

  Future<Map<String, MemoModel>> getUserMemos() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('memo')
          .get();

      Map<String, MemoModel> memos = {};
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        memos[doc.id] = MemoModel(
          memoId: doc.id,
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          category: data['category'] ?? '',
          question: data['question'] ?? '',
          isImportant: data['isImportant'] ?? false,
          tags: List<String>.from(data['tags'] ?? []),
          lastModified: data['lastModified'] is Timestamp
              ? (data['lastModified'] as Timestamp).toDate()
              : data['lastModified'],
          createdAt: data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp).toDate()
              : (data['createdAt'] ?? DateTime.now()),
        );
      }
      debugPrint("✅ 메모 데이터 가져오기 성공: ${memos.length}개");
      return memos;
    } catch (e) {
      debugPrint("❌ 메모 가져오기 실패: $e");
      return {};
    }
  }

  Future<List<String>> getUserCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('categories')
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      // 첫 번째 문서의 categories 필드 가져오기
      final data = querySnapshot.docs.first.data();
      List<String> categories = List<String>.from(data['categories'] ?? []);
      debugPrint("✅ 카테고리 데이터 가져오기 성공: ${categories.length}개");
      return categories;
    } catch (e) {
      debugPrint("❌ 카테고리 가져오기 실패: $e");
      return [];
    }
  }

  // Todo 관련 코드는 별도의 서비스로 분리
  /*
  Future<void> saveTodo(TodoModel todo, String uuid) async {
    await _firestore
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .collection("todo")
        .doc(uuid)
        .set({
      'todo': todo.todoContent,
      'isImportant': todo.isImportant,
      'lastModified': todo.lastModified,
      'createdAt': todo.createdAt,
      'isDone': todo.isDone,
      'todoId': todo.todoId,
    });
  }

  // updateTodo 메서드 추가
  Future<void> updateTodo(TodoModel todo, String uuid) async {
    await _firestore
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .collection("todo")
        .doc(uuid)
        .set({
      'todo': todo.todoContent,
      'isImportant': todo.isImportant,
      'lastModified': DateTime.now(), // 항상 현재 시간으로 업데이트
      'createdAt': todo.createdAt,
      'isDone': todo.isDone,
      'memoId': todo.todoId,
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
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('todo')
          .get();

      Map<String, TodoModel> todos = {};
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        todos[doc.id] = TodoModel(
          todoContent: data['todo'] ?? '',
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
  */
}
