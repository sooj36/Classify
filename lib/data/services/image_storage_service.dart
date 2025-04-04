import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

class ImageStorageService {
  static final Dio _dio = Dio();
  
  Future<String> downloadAndSaveImage(String imageUrl) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${appDir.path}/cloth_images');
      
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      // dio로 이미지 다운로드
      final response = await _dio.get<List<int>>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode != 200) {
        throw Exception('이미지 다운로드 실패');
      }

      final fileName = path.basename(imageUrl);
      final filePath = '${imageDir.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(response.data!);

      return filePath;
    } catch (e) {
      throw Exception('이미지 저장 실패: $e');
    }
  }

  Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('이미지 삭제 실패: $e');
    }
  }
} 