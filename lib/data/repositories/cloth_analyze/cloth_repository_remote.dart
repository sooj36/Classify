import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weathercloset/data/repositories/cloth_analyze/cloth_repository.dart';
import 'package:weathercloset/data/services/gemini_service.dart';
import 'package:weathercloset/domain/models/cloth/cloth_model.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';
import 'package:weathercloset/data/services/firestore_service.dart';
import 'package:flutter/material.dart';
class ClothRepositoryRemote extends ClothRepository {
  final GeminiService _geminiService;
  final ImagePicker _picker;
  final FirestoreService _firestoreService;
  ClothRepositoryRemote({
    required GeminiService geminiService,
    required FirestoreService firestoreService,
  }) : _geminiService = geminiService,
       _picker = ImagePicker(),
       _firestoreService = firestoreService;

  @override
  Future<bool> requestPermissions() async {
    final camera = await Permission.camera.request();
    final storage = await Permission.storage.request();
    return camera.isGranted && storage.isGranted;
  }

  @override
  Future<ClothModel> getImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    final bytes = await image?.readAsBytes();
    final response = await analyzeImage(bytes);
    return ClothModel(imagePath: image?.path ?? '', response: response);
  }

  @override
  Future<ClothModel> getImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    final bytes = await image?.readAsBytes();
    final response = await analyzeImage(bytes);
    return ClothModel(imagePath: image?.path ?? '', response: response);
  }

  @override
  Future<String> analyzeImage(Uint8List? bytes) async {
    return await _geminiService.analyzeImage(bytes);
  }

  @override
  Future<void> saveCloth(ClothModel cloth) async {
    final file = File(cloth.imagePath!);
    // 옷 데이터 정리
    String cleanJson = cloth.response!
    .replaceAll("```json", "")
    .replaceAll("```", "");
    final responseMap = jsonDecode(cleanJson);
    //firestore에 저장
    await _firestoreService.saveCloth(responseMap);
    debugPrint("✅ 옷 저장 성공!");
  }

  @override
  Stream<List<ClothModel>> watchCloth() {
    final clothStream = _firestoreService.watchCloth();
    
    return clothStream.map(
      (snapshot) {
      return snapshot.docs.map(
          (doc) {
         Map<String, dynamic> data = doc.data() as Map<String, dynamic>; 
        debugPrint("✅ 옷 데이터 체크! - clothrepositoryremote - ${data["대분류"]}");
        debugPrint("✅ 옷 데이터 체크! - clothrepositoryremote - ${data["소분류"]}");
        debugPrint("✅ 옷 데이터 체크! - clothrepositoryremote - ${data["색깔"]}");
        debugPrint("✅ 옷 데이터 체크! - clothrepositoryremote - ${data["재질"]}");
        return ClothModel(
          major: data["대분류"] as String? ?? "",
          minor: data["소분류"] as String? ?? "",
          color: data["색깔"] as String? ?? "",
          material: data["재질"] as String? ?? "",
          );
        }
      )
      .toList();
    });
  }
} 