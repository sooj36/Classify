import 'package:flutter/material.dart';
import '../../../../repositories/cloth_repository.dart';
import '../../../../domain/models/cloth/cloth_model.dart';

class ClothAddViewModel extends ChangeNotifier {
  final ClothRepository _repository;
  ClothModel? _cloth;
  bool _isLoading = false;
  String? _error;

  ClothAddViewModel(this._repository);

  ClothModel? get cloth => _cloth;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> takePhoto() async {
    try {
      _setLoading(true);
      final hasPermission = await _repository.requestPermissions();
      if (!hasPermission) {
        throw '카메라 및 저장소 권한이 필요합니다.';
      }
      
      final imagePath = await _repository.getImageFromCamera();
      if (imagePath != null) {
        _cloth = ClothModel(imagePath: imagePath);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> pickFromGallery() async {
    try {
      _setLoading(true);
      final imagePath = await _repository.getImageFromGallery();
      if (imagePath != null) {
        _cloth = ClothModel(imagePath: imagePath);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
} 