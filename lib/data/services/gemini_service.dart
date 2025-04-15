import 'package:flutter/material.dart';
import 'package:weathercloset/global/global.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:weathercloset/domain/models/memo/memo_model.dart';
import 'dart:convert';
class GeminiService {


  // ${categories.join(', ')} <- 카테고리를 동적으로 조정하고 싶으면 이렇게 하면 됨.
  Future<MemoModel> analyzeMemo(String memoText, List<String> categories, String memoId) async {
    try {
      debugPrint('🔍 분류 기준: $categories');
      String prompt = '''
        아래의 메모를 분류해줘
        $memoText
        분류할 수 있는 카테고리는 다음과 같아
        할 일, 공부, 아이디어 중 하나로 분류해야 해.
        그리고 10자 이내의 적절한 제목도 붙여줘야 해.
        또한 메모 원문을 그대로 복사해서 붙여넣어야 해.
        마지막으로 1개에서 3개의 태그를 붙여야 해.
        특히 조심해. 아래의 JSON 형식은 말 그대로 예시일 뿐이고 네가 적절히 판단해서 최적의 태그 갯수를 산정한 다음에 태그를 붙이도록 해.
        그리고 마지막으로 메모 원문을 보고 카테고리가 공부라고 판단했을 경우 이 내용을 가지고 복습이 가능하도록 질문을 하나 만들어줘.
        아래와 같이 JSON 형식으로 답변할 수 있도록 해
        {
          "category": "카테고리",
          "title": "제목",
          "content": "메모 원문",
          "tags": ["태그1", "태그2", ...],
          "question": "content 내용으로 만든 질문"
        }
      ''';

      final contentList = [
        Content.multi([
          TextPart(prompt),
        ])
      ];

      var response = await model!.generateContent(contentList);
      var responseText = response.text ?? '{"category":"할 일", "title":"기본 제목", "content":"내용 없음", "tags":[]}';
      responseText = responseText.replaceAll('```json', '').replaceAll('```', '');
      
      // JSON 파싱 전에 유효한 JSON인지 확인
      bool isValidJson = responseText.trim().startsWith('{') && responseText.trim().endsWith('}');
      if (!isValidJson) {
        debugPrint('⚠️ 유효하지 않은 AI 응답: $responseText');
        // 기본 JSON으로 대체
        responseText = '{"category":"할 일", "title":"기본 제목", "content":"$memoText", "tags":[]}';
      }
      
      Map<String, dynamic> parsedResponse;
      try {
        parsedResponse = jsonDecode(responseText);
      } catch (e) {
        debugPrint('⚠️ JSON 파싱 오류: $e');
        parsedResponse = {
          "category": "할 일",
          "title": "기본 제목",
          "content": memoText,
          "tags": [],
          "question": "질문"
        };
      }

      // null 체크 및 기본값 설정
      final String category = parsedResponse['category'] as String? ?? (categories.isNotEmpty ? categories.first : "할 일");
      final String title = parsedResponse['title'] as String? ?? "기본 제목";
      final String memoContent = parsedResponse['content'] as String? ?? memoText;
      
      // tags가 null이거나 List<dynamic>이 아닌 경우 빈 배열 사용
      List<String> tags = [];
      if (parsedResponse['tags'] != null && parsedResponse['tags'] is List) {
        tags = List<String>.from(
          (parsedResponse['tags'] as List).map((item) => item?.toString() ?? "").toList()
        );
      }

      MemoModel memo = MemoModel(
        memoId: memoId,
        category: category, 
        title: title, 
        content: memoContent, 
        tags: tags,
        isImportant: false, 
        lastModified: DateTime.now(), 
        createdAt: DateTime.now()
      );
      
      if (category == '할 일') {
        memo = memo.copyWith(isDone: false);
      }

      if (category == '공부') {
        memo = memo.copyWith(question: parsedResponse['question'] as String? ?? "");
      }
      
      debugPrint('✅ 메모 분류 완료');
      return memo;
    } catch (e) {
      debugPrint('❌ 메모 분류 중 오류 발생: $e');
      // 오류 발생 시 기본 MemoModel 반환
      return MemoModel(
        memoId: memoId,
        category: (categories.isNotEmpty ? categories.first : "할 일"),
        title: "처리 실패한 메모",
        content: memoText,
        tags: [],
        isImportant: false,
        lastModified: DateTime.now(),
        createdAt: DateTime.now(),
        isDone: false,
      );
    }
  }
}