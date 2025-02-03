import 'package:flutter/material.dart';
import 'package:weathercloset/domain/models/cloth/cloth_model.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ClothRepository extends ChangeNotifier {

  Future<bool> requestPermissions();

  Future<ClothModel> getImageFromCamera();

  Future<ClothModel> getImageFromGallery();

  Future<String> analyzeImage(Uint8List bytes);

  Future<void> saveCloth(ClothModel cloth);

  Stream<List<ClothModel>> watchCloth();
} 