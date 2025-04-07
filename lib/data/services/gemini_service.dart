import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:weathercloset/global/global.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {

  Future<String> analyzeImage(Uint8List? bytes) async {
      final content = [
        Content.multi([
          TextPart(clothAnalysisJson),
          DataPart('image/jpeg', bytes!), // 선택한 이미지 전송
        ])
      ];

      var response = await model!.generateContent(content);
      var text = response.text;
      debugPrint('✅ 이미지 분석 완료');
      return text ?? '';
  }

  Future<String> requestCoordi(Map<String, dynamic> request) async {
    final content = [
      Content.multi([
        TextPart(request.toString()),
      ])
    ];
    var response = await model!.generateContent(content);
    var text = response.text;
    debugPrint('✅ 코디 분석 완료');
    return text ?? '';
  }


}