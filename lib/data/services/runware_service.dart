import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class RunwareService {
  final String _apiKey = 'mUupomybPRmwNrUjnb02Ch4wsbdvmTX4';
  final String _apiUrl = 'https://api.runware.ai/v1';
  final String _uuid = const Uuid().v4();
  final Dio _dio = Dio();

  RunwareService() {
    // Dio 인터셉터 설정
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('🔍 DIO 요청 인터셉트:');
        debugPrint('🔍 URL: ${options.uri}');
        debugPrint('🔍 메서드: ${options.method}');
        debugPrint('🔍 헤더: ${options.headers}');
        
        // 요청 본문 출력 (JSON 형태로 예쁘게 출력)
        if (options.data != null) {
          try {
            final prettyJson = const JsonEncoder.withIndent('  ').convert(options.data);
            debugPrint('🔍 요청 본문:\n$prettyJson');
          } catch (e) {
            debugPrint('🔍 요청 본문: ${options.data}');
          }
        }
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('🔍 DIO 응답 인터셉트:');
        debugPrint('🔍 상태 코드: ${response.statusCode}');
        
        // 응답 본문 출력 (JSON 형태로 예쁘게 출력)
        try {
          final prettyJson = const JsonEncoder.withIndent('  ').convert(response.data);
          debugPrint('🔍 응답 본문:\n$prettyJson');
        } catch (e) {
          debugPrint('🔍 응답 본문: ${response.data}');
        }
        
        return handler.next(response);
      },
      onError: (error, handler) {
        debugPrint('🔍 DIO 에러 인터셉트:');
        debugPrint('🔍 에러 메시지: ${error.message}');
        debugPrint('🔍 에러 응답: ${error.response?.data}');
        return handler.next(error);
      },
    ));
  }

  Future<String> generateImage(String positiveprompt) async {
    final Uri url = Uri.parse('https://api.runware.ai/v1');

    // curl과 정확히 동일한 형식으로 맞추기
    final Map<String, dynamic> requestData = {
      "taskType": "imageInference",
      "taskUUID": _uuid,
      "positivePrompt": positiveprompt,  // 파라미터 사용
      "model": "runware:101@1",
      "width": 1024,
      "height": 1024,
      "numberResults": 1,
      "outputFormat": "JPEG",
      "steps": 28,
      "CFGScale": 3.5,
      "scheduler": "FlowMatchEulerDiscreteScheduler",
      "outputType": "URL",
      "includeCost": false,
      "seed": 5533262550305924,
      "lora": [
        {
          "model": "civitai:180891@838667",
          "weight": 1
        }
      ]
    };

    // curl과 동일하게 배열 형태로 전송
    final List<Map<String, dynamic>> requestBody = [requestData];
    
    // 디버그 출력
    debugPrint("✅ HTTP 요청 메서드: POST");
    debugPrint("✅ HTTP 요청 URL: $url");
    debugPrint("✅ HTTP 요청 헤더: Content-Type: application/json, Authorization: Bearer ${_apiKey.substring(0, 5)}...");
    
    // 에러 응답도 자세히 확인하기 위해 try-catch 추가
    try {
      // Dio를 사용한 요청 (인터셉터가 자동으로 로깅)
      final dioResponse = await _dio.post(
        _apiUrl,
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
        ),
      );

      // 응답 처리
      if (dioResponse.statusCode == 200) {
        final responseData = dioResponse.data;
        
        if (responseData is List && responseData.isNotEmpty) {
          if (responseData[0].containsKey('result')) {
            return responseData[0]['result'];
          }
        }
        
        // 응답 구조 디버깅
        debugPrint("✅ 응답 데이터 구조: ${responseData.runtimeType}");
        
        // 응답에서 result 추출 시도
        if (responseData is Map && responseData.containsKey('result')) {
          return responseData['result'];
        } else if (responseData is List && responseData.isNotEmpty && responseData[0].containsKey('result')) {
          return responseData[0]['result'];
        }
        
        // 그래도 없으면 전체 응답 반환
        return jsonEncode(responseData);
      } else {
        throw Exception('API 요청 실패: 상태 코드 ${dioResponse.statusCode}, 응답: ${dioResponse.data}');
      }
    } catch (e) {
      debugPrint("❌ 예외 발생: $e");
      rethrow;
    }
  }
}
