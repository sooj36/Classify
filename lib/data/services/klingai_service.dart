
import 'package:dio/dio.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/foundation.dart';

class KlingService {
  static const String baseUrl = 'https://api.klingai.com/v1';
  final String accessKey = 'ee978c9bb2ce42f38c5c8a78326524f4';
  final String secretKey = '7f55e6361f534c3aa13ee740209f1912';
  final Dio _dio;

  KlingService() : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ));

  String generateToken() {
    final jwt = JWT(
      {
        'iss': accessKey,
        'exp': DateTime.now().add(const Duration(minutes: 30)).millisecondsSinceEpoch ~/ 1000,
        'nbf': DateTime.now().subtract(const Duration(seconds: 5)).millisecondsSinceEpoch ~/ 1000,
      },
      header: {
        'alg': 'HS256',
        'typ': 'JWT',
      },
    );

    return jwt.sign(SecretKey(secretKey));
  }

  Future<String> virtualTryOn({
    required String humanImageBase64,
    required String clothImageBase64,
  }) async {
    final token = generateToken();
    debugPrint('token: $token');
    debugPrint('url: $baseUrl/images/kolors-virtual-try-on');
    
    try {
      debugPrint('Dio 요청 시작');
      final response = await _dio.post(
        '/images/kolors-virtual-try-on',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) => true,
        ),
        data: {
          'model_name': 'kolors-virtual-try-on-v1-5',
          'human_image': humanImageBase64,
          'cloth_image': clothImageBase64,
        },
      );
      
      debugPrint('Dio 응답 상태 코드: ${response.statusCode}');
      debugPrint('Dio 응답: ${response.data}');

      if (response.statusCode == 200) {
        final taskId = response.data['data']['task_id'];
        debugPrint('작업 ID 수신: $taskId');
        
        // 작업 완료될 때까지 폴링
        return await _pollTaskResult(taskId, token);
      } else {
        throw Exception('Failed to process virtual try-on: ${response.statusMessage}, ${response.data}');
      }
    } on DioException catch (e) {
      debugPrint('Dio 오류 타입: ${e.type}');
      debugPrint('Dio 오류 메시지: ${e.message}');
      debugPrint('Dio 오류 응답: ${e.response?.data}');
      
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Response timeout. The server took too long to respond.');
      } else if (e.type == DioExceptionType.badCertificate) {
        throw Exception('Bad SSL certificate. Connection could not be established securely.');
      } else {
        throw Exception('Failed to connect to the server: ${e.message}');
      }
    } catch (e) {
      debugPrint('기타 오류: $e');
      rethrow;
    }
  }

  // 작업 결과를 폴링하는 메서드 추가
  Future<String> _pollTaskResult(String taskId, String token) async {
    debugPrint('작업 결과 폴링 시작: $taskId');
    
    // 최대 시도 횟수
    const maxAttempts = 30;
    // 폴링 간격 (밀리초)
    const pollingInterval = 2000;
    
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      debugPrint('폴링 시도 $attempt/$maxAttempts');
      
      try {
        final response = await _dio.get(
          '/images/kolors-virtual-try-on/$taskId',
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ),
        );
        
        debugPrint('폴링 응답 상태 코드: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final taskStatus = response.data['data']['task_status'];
          debugPrint('작업 상태: $taskStatus');
          
          if (taskStatus == 'succeed') {
            debugPrint('작업 완료됨');
            
            // task_result에서 이미지 URL 추출
            final taskResult = response.data['data']['task_result'];
            if (taskResult != null && 
                taskResult['images'] != null && 
                (taskResult['images'] as List).isNotEmpty) {
              
              final imageUrl = taskResult['images'][0]['url'];
              debugPrint('이미지 URL: $imageUrl');
              
              // URL과 함께 결과 반환
              return imageUrl;
            }
            return '';
          } else if (taskStatus == 'failed') {
            final errorMsg = response.data['data']['task_status_msg'] ?? 
                            '알 수 없는 오류';
            debugPrint('작업 실패: $errorMsg');
            throw Exception('작업 처리 실패: $errorMsg');
          }
        } else {
          debugPrint('폴링 응답 오류: ${response.data}');
        }
      } catch (e) {
        debugPrint('폴링 중 오류 발생: $e');
        // 폴링 중 오류가 발생해도 계속 시도
      }
      
      // 다음 폴링 전 대기
      await Future.delayed(const Duration(milliseconds: pollingInterval));
    }
    
    // 최대 시도 횟수 초과
    throw Exception('작업 결과를 가져오는 시간이 초과되었습니다. 나중에 다시 시도해주세요.');
  }
} 