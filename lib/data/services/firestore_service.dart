import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weathercloset/domain/models/auth/signup_user_model.dart';
import 'package:weathercloset/global/global.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';


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

  // Future<void> updateUser({required UserModel user}) async {
  //   await _firestore.collection("users").doc(user.uid).update();
  // }

  Future<void> deleteUser() async {
    await _firestore.collection("users").doc(firebaseAuth.currentUser!.uid).delete();
  }

  Future<void> saveCloth(Map<String, dynamic> cloth, XFile file, String uuid) async {
    final localFile = File(file.path);
    // Check if the file exists
    if (!await localFile.exists()) {
      debugPrint("❌ File not found at: ${file.path} in [saveCloth method] in [firestore_service]");
      throw Exception("File not found");
    }
    
    // Create metadata for the file
    final metadata = SettableMetadata(contentType: "image/jpeg");
    
    // Generate a unique storage path
    final storagePath = "cloth_images/${DateTime.now().millisecondsSinceEpoch}.jpg";
    final storageRef = FirebaseStorage.instance.ref().child(storagePath);
    
    // Start the upload task
    final uploadTask = storageRef.putFile(localFile, metadata);
    
    // Listen for state changes using snapshotEvents
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      switch (snapshot.state) {
        case TaskState.running:
          final progress = 100.0 * (snapshot.bytesTransferred / snapshot.totalBytes);
          debugPrint("Upload is ${progress.toStringAsFixed(2)}% complete.");
          break;
        case TaskState.paused:
          debugPrint("Upload is paused.");
          break;
        case TaskState.canceled:
          debugPrint("Upload was canceled.");
          break;
        case TaskState.error:
          debugPrint("Upload encountered an error.");
          break;
        case TaskState.success:
          debugPrint("Upload succeeded.");
          break;
      }
    });
    
    // Await for the upload task to complete
    final snapshot = await uploadTask;
    if (snapshot.state == TaskState.success) {
      final downloadUrl = await snapshot.ref.getDownloadURL();
      cloth["imagePath"] = downloadUrl;
    
      await _firestore
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .collection("cloths")
        .doc(uuid)
        .set(cloth);
      debugPrint("✅ Cloth saved successfully!");
    } else {
      debugPrint("❌ Upload failed with state: ${snapshot.state} in [saveCloth method] in [firestore_service]");
      throw Exception("Upload failed");
    }
  }

  Stream<QuerySnapshot> watchCloth() {
    return _firestore
    .collection("users")
    .doc(firebaseAuth.currentUser!.uid)
    .collection("cloths")
    .snapshots();
  }

  Future<void> deleteCloth(String clothId) async {
    await _firestore.collection("users").doc(firebaseAuth.currentUser!.uid).collection("cloths").doc(clothId).delete();
  }

  // Future<UserModel> getUser({required UserModel user}) async {
  //   final userData = await _firestore.collection("users").doc(user.uid).get();
  //   return UserModel(
  //     uid: userData.data()?["userUID"],
  //     email: userData.data()?["userEmail"],
  //     name: userData.data()?["userName"],
  //     phone: userData.data()?["phone"],
  //     status: userData.data()?["status"],
  //   );
  // }
}
