import 'package:flutter/material.dart';
import '../../../../data/repositories/memo_analyze/memo_analyze_repository_remote.dart';
import '../../../../domain/models/cloth/cloth_model.dart';

class ArchiveAddViewModel extends ChangeNotifier {
  final MemoAnalyzeRepositoryRemote _memoAnalyzeRepositoryRemote;
  ClothModel? _cloth;
  String? _analyzeResult;
  bool _isLoading = false;
  String? _error;

  ArchiveAddViewModel({
    required MemoAnalyzeRepositoryRemote memoAnalyzeRepositoryRemote,
  }) : _memoAnalyzeRepositoryRemote = memoAnalyzeRepositoryRemote;

  ClothModel? get cloth => _cloth;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get analyzeResult => _analyzeResult;

  Future<void> takePhoto() async {
    try {
      _setLoading(true);
      // final hasPermission = await _clothRepositoryRemote.requestPermissions();
      // if (!hasPermission) {
      //   throw '카메라 및 저장소 권한이 필요합니다.';
      // }
      final clothModel = await _memoAnalyzeRepositoryRemote.getImageFromCamera();
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
      final clothModel = await _memoAnalyzeRepositoryRemote.getImageFromGallery();
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

  Future<void> saveCloth() async {
    await _memoAnalyzeRepositoryRemote.saveCloth(cloth!);
  }
} 