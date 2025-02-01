import 'dart:io';
import '../../global/global.dart';
import 'package:flutter/material.dart';

class GeminiService {
  Future<String> analyzeImage(String imagePath) async {
    try {
      final image = File(imagePath);
          // 파일 존재 여부 체크 추가
      if (!await image.exists()) {
      throw Exception('이미지 파일을 찾을 수 없습니다');
      } else {
        debugPrint('✅ 이미지 파일 존재 확인');
        debugPrint('✅ 이미지 경로: ${image.absolute.path}');
      }
      final imagetest = File("assets/dress.jpg");
      debugPrint('✅ 이미지 분석 시작');
      final response = await gemini!.generateFromTextAndImages(
        query: "What is this picture?",
        image: imagetest,
      );
      debugPrint('✅ 이미지 분석 완료');
      
      return response.text;
    } catch (e) {
      throw Exception('이미지 분석에 실패했습니다');
    }
  }


}