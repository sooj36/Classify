import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../global/global.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  Future<String> analyzeImage(Uint8List? bytes) async {
      final content = [
        Content.multi([
          TextPart("Analyze this image and describe what you see"),
          DataPart('image/jpeg', bytes!), // 선택한 이미지 전송
        ])
      ];

      var response = await model!.generateContent(content);
      var text = response.text;
      debugPrint('✅ 이미지 분석 완료');
      return text ?? '';
  }


}