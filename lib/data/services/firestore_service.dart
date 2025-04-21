import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weathercloset/domain/models/auth/signup_user_model.dart';
import 'package:weathercloset/global/global.dart';
import 'package:flutter/foundation.dart';
import 'package:weathercloset/domain/models/memo/memo_model.dart';


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
    await _firestore.collection("users").doc(firebaseAuth.currentUser!.uid).delete();
    debugPrint("✅ 회원 탈퇴 성공");
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
    await _firestore.collection("users").doc(firebaseAuth.currentUser!.uid).collection("memo").doc(uuid).set({
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

  Stream<QuerySnapshot> watchMemo() {
    return _firestore
    .collection("users")
    .doc(firebaseAuth.currentUser!.uid)
    .collection("memo")
    .snapshots();
  }

  Future<void> deleteMemo(String memoId) async {
    await _firestore.collection("users").doc(firebaseAuth.currentUser!.uid).collection("memo").doc(memoId).delete();
  }

  Future<void> createCategoryWhenSignup() async {
    await _firestore.collection("users").doc(firebaseAuth.currentUser!.uid).collection("categories").add({
      "categories": ["아이디어", "공부", "할 일", "업무", "스크랩"],
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
}
