import 'package:flutter/material.dart';
import 'package:weathercloset/global/global.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:weathercloset/domain/models/memo/memo_model.dart';
import 'dart:convert';
class GeminiService {

  Future<MemoModel> analyzeMemo(String memoText, List<String> categories) async {
    debugPrint('🔍 분류할 메모: $categories');
    String prompt = '''
      아래의 메모를 분류해줘
      $memoText
      분류할 수 있는 카테고리는 다음과 같아
      ${categories.join(', ')}
      그리고 10자 이내의 적절한 제목도 붙여줘야 해. 아래와 같이 JSON 형식으로 답변할 수 있도록 해
      {
        "category": "카테고리",
        "title": "제목",
        "content": "메모 원문"
      }
    ''';

    final content = [
      Content.multi([
        TextPart(prompt),
      ])
    ];

    var response = await model!.generateContent(content);
    var parsedResponse = jsonDecode(response.text!.replaceAll('```json', '').replaceAll('```', ''));

    MemoModel memo = MemoModel(
      category: parsedResponse['category'], 
      title: parsedResponse['title'], 
      content: parsedResponse['content'], 
      isImportant: false, 
      tags: [], 
      lastModified: DateTime.now(), 
      createdAt: DateTime.now()
    );

    debugPrint('✅ 메모 분류 완료');
    return memo;
  }
}