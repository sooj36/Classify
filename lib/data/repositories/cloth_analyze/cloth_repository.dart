import 'package:flutter/material.dart';
import 'package:weathercloset/domain/models/cloth/cloth_model.dart';
import 'dart:typed_data';

abstract class ClothRepository extends ChangeNotifier {

  Future<bool> requestPermissions();

  Future<ClothModel> getImageFromCamera();

  Future<ClothModel> getImageFromGallery();

  Future<String> analyzeImage(Uint8List bytes);

  Future<void> saveCloth(ClothModel cloth);

  Stream<List<ClothModel>> watchClothRemote();

  Stream<Map<String, ClothModel>> watchClothLocal();

  Future<String> requestCoordi(Map<String, dynamic> request);
} 
