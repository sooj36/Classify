


import 'dart:io';
import '../../global/global.dart';

class GeminiService {
  Future<String> analyzeImage(String imagePath) async {
    try {
      final image = File(imagePath);
      final response = await gemini!.generateFromTextAndImages(
        query: "What is this picture?",
        image: image,
      );
      
      return response.text;
    } catch (e) {
      throw Exception('이미지 분석에 실패했습니다');
    }
  }


}