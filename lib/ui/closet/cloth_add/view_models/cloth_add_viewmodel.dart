import 'package:flutter/material.dart';
import '../../../../data/repositories/cloth_analyze/cloth_repository_remote.dart';
import '../../../../domain/models/cloth/cloth_model.dart';

class ClothAddViewModel extends ChangeNotifier {
  final ClothRepositoryRemote _clothRepositoryRemote;
  ClothModel? _cloth;
  String? _analyzeResult;
  bool _isLoading = false;
  String? _error;

  ClothAddViewModel({
    required ClothRepositoryRemote clothRepositoryRemote,
  }) : _clothRepositoryRemote = clothRepositoryRemote;

  ClothModel? get cloth => _cloth;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get analyzeResult => _analyzeResult;

  Future<void> takePhoto() async {
    try {
      _setLoading(true);
      final hasPermission = await _clothRepositoryRemote.requestPermissions();
      if (!hasPermission) {
        throw '카메라 및 저장소 권한이 필요합니다.';
      }
      final clothModel = await _clothRepositoryRemote.getImageFromCamera();
      _cloth = clothModel;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> pickFromGallery() async {
    try {
      _setLoading(true);
      final clothModel = await _clothRepositoryRemote.getImageFromGallery();
      _cloth = clothModel;
      notifyListeners();
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