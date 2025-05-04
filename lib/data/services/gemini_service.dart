import 'package:flutter/material.dart';
import 'package:classify/domain/models/memo/memo_model.dart';
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';

class GeminiService {
  final FirebaseFunctions _functions;

  GeminiService() : _functions = FirebaseFunctions.instance;

  Future<MemoModel> analyzeMemo(
      String memoText, List<String> categories, String memoId) async {
    try {
      debugPrint('🔍 분류 기준: $categories');

      // Firebase Functions SDK의 httpsCallable 사용
      final callable = _functions.httpsCallable(
        'analyzeMemo',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 30),
        ),
      );

      // 함수 호출을 위한 데이터 준비
      final Map<String, dynamic> requestData = {
        'memoText': memoText,
        'categories': categories,
      };
      // 함수 호출
      debugPrint('📡 Firebase Functions 요청: $requestData');
      final response = await callable(requestData);
      final data = response.data;
      debugPrint('📡 Firebase Functions 응답: $data');

      // 응답 파싱
      Map<String, dynamic> parsedResponse;
      try {
        if (data is Map<String, dynamic>) {
          parsedResponse = data;
        } else if (data is String) {
          parsedResponse = jsonDecode(data);
        } else {
          throw Exception('예상치 못한 응답 형식');
        }
      } catch (e) {
        debugPrint('⚠️ JSON 파싱 오류: $e');
        parsedResponse = {
          "category": categories.isNotEmpty ? categories.first : "기타+",
          "title": "기본 제목",
          "content": memoText,
          "tags": [],
          "question": ""
        };
      }

      // null 체크 및 기본값 설정
      final String category = parsedResponse['category'] as String? ??
          (categories.isNotEmpty ? categories.first : "기타+");
      final String title = parsedResponse['title'] as String? ?? "기본 제목";
      final String memoContent =
          parsedResponse['content'] as String? ?? memoText;

      // tags가 null이거나 List<dynamic>이 아닌 경우 빈 배열 사용
      List<String> tags = [];
      if (parsedResponse['tags'] != null && parsedResponse['tags'] is List) {
        tags = List<String>.from((parsedResponse['tags'] as List)
            .map((item) => item?.toString() ?? "")
            .toList());
      }

      MemoModel memo = MemoModel(
          memoId: memoId,
          category: category,
          title: title,
          content: memoContent,
          tags: tags,
          isImportant: false,
          lastModified: DateTime.now(),
          createdAt: DateTime.now());

      // if (category == '할 일') {
      //   memo = memo.copyWith(isDone: false);
      // }

      if (category == '공부') {
        memo = memo.copyWith(
            question: parsedResponse['question'] as String? ?? "");
      }

      debugPrint('✅ 메모 분류 완료');
      return memo;
    } catch (e) {
      debugPrint('❌ 메모 분류 중 일반 오류 발생: $e');
      // 오류 발생 시 기본 MemoModel 반환
      return MemoModel(
        memoId: memoId,
        category: "AI분류 실패",
        title: "AI분류 실패한 메모",
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
