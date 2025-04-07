import 'package:flutter/material.dart';
import 'package:weathercloset/domain/models/cloth/cloth_model.dart';
import 'dart:typed_data';

abstract class MemoAnalyzeRepository extends ChangeNotifier {

  Future<bool> requestPermissions();

  Future<ClothModel> getImageFromCamera();

  Future<ClothModel> getImageFromGallery();

  Future<String> analyzeImage(Uint8List bytes);

  Future<void> saveCloth(ClothModel cloth);

  Stream<List<ClothModel>> watchClothRemote();

  Stream<Map<String, ClothModel>> watchClothLocal();

  Future<String> requestCoordi(Map<String, dynamic> request);

  List<ClothModel> getCoordiClothes(String response, Map<String, ClothModel> cachedClothes);

  String getCoordiTexts(String response);

  Future<String> getFinalCoordiImage(List<ClothModel> coordiClothes);

  Future<void> deleteCloth(String clothId);
} 