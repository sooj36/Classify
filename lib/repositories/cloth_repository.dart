import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/services/gemini_service.dart';

class ClothRepository {
  final ImagePicker _picker = ImagePicker();

  Future<bool> requestPermissions() async {
    final camera = await Permission.camera.request();
    final storage = await Permission.storage.request();
    return camera.isGranted && storage.isGranted;
  }

  Future<String?> getImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    delivertoservice(image?.path ?? '');
    return image?.path;
  }

  Future<String?> getImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    delivertoservice(image?.path ?? '');
    return image?.path;
  }

  delivertoservice(String imagePath) {
    // GeminiService.analyzeImage(imagePath);
  }
} 