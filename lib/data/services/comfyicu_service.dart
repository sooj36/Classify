import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ComfyICUService {
  final Dio _dio;
  static const String _apiKey = 'EcPFBRDYq9mDzesIkatKarSP5vfUED6ObGENPy17oSVlZW55'; // API 키 하드코딩
  static const String _baseUrl = 'https://comfy.icu/api/v1';

  ComfyICUService() 
    : _dio = Dio(BaseOptions(
        baseUrl: _baseUrl,
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          'authorization': 'Bearer $_apiKey'
        },
      ));

  Future<String> processImage(String inputImageUrl) async {
    debugPrint('[ComfyICU] 이미지 처리 시작');
    const String workflowId = 'dpX4u7m7g9HUEEJMFLBSi';

        final Map<String, dynamic> prompt = {
      "1": {
        "_meta": {"title": "GroundingDinoModelLoader (segment anything)"},
        "inputs": {"model_name": "GroundingDINO_SwinB (938MB)"},
        "class_type": "GroundingDinoModelLoader (segment anything)"
      },
      "2": {
        "_meta": {"title": "SAMModelLoader (segment anything)"},
        "inputs": {"model_name": "sam_hq_vit_h (2.57GB)"},
        "class_type": "SAMModelLoader (segment anything)"
      },
      "3": {
        "_meta": {"title": "Load Image"},
        "inputs": {"image": "input_image.png", "upload": "image"},
        "class_type": "LoadImage"
      },
      "4": {
        "_meta": {"title": "GroundingDinoSAMSegment (segment anything)"},
        "inputs": {
          "image": ["3", 0],
          "prompt": "upper garment",
          "sam_model": ["2", 0],
          "threshold": 0.3,
          "grounding_dino_model": ["1", 0]
        },
        "class_type": "GroundingDinoSAMSegment (segment anything)"
      },
      "5": {
        "_meta": {"title": "InvertMask (segment anything)"},
        "inputs": {"mask": ["4", 1]},
        "class_type": "InvertMask (segment anything)"
      },
      "6": {
        "_meta": {"title": "Convert Mask to Image"},
        "inputs": {"mask": ["5", 0]},
        "class_type": "MaskToImage"
      },
      "7": {
        "_meta": {"title": "Preview Image"},
        "inputs": {"images": ["6", 0]},
        "class_type": "PreviewImage"
      },
      "13": {
        "_meta": {"title": "Preview Image"},
        "inputs": {"images": ["4", 0]},
        "class_type": "PreviewImage"
      },
      "17": {
        "_meta": {"title": "Image Rembg (Remove Background)"},
        "inputs": {
          "model": "u2net",
          "images": ["4", 0],
          "only_mask": false,
          "transparency": true,
          "alpha_matting": false,
          "post_processing": false,
          "background_color": "none",
          "alpha_matting_erode_size": 10,
          "alpha_matting_background_threshold": 10,
          "alpha_matting_foreground_threshold": 240
        },
        "class_type": "Image Rembg (Remove Background)"
      },
      "18": {
        "_meta": {"title": "Save Image"},
        "inputs": {"images": ["17", 0], "filename_prefix": "ComfyUI"},
        "class_type": "SaveImage"
      }
    };

    final Map<String, dynamic> files = {
      "/input/input_image.png": inputImageUrl
    };

    try {
      debugPrint('[ComfyICU] 이미지 처리 시작');
      // 워크플로우 실행
      final response = await _runWorkflow(workflowId, prompt, files);
      final String runId = response['id'];
      
      // 상태 폴링
      final finalStatus = await _pollStatus(workflowId, runId);
      debugPrint('[ComfyICU] 상태 폴링 완료: $finalStatus');
      
      // 결과 URL 추출
      if (finalStatus['output'] != null && 
          finalStatus['output'] is List && 
          finalStatus['output'].isNotEmpty) {
        final outputItem = finalStatus['output'][0];
        if (outputItem is Map && outputItem.containsKey('url')) {
          return outputItem['url'];
        }
      }
      
      throw Exception('이미지 URL을 찾을 수 없습니다');
    } catch (e) {
      debugPrint('[ComfyICU] 오류 발생: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _runWorkflow(
    String workflowId, 
    Map<String, dynamic> prompt, 
    Map<String, dynamic> files
  ) async {
    try {
      final response = await _dio.post(
        '/workflows/$workflowId/runs',
        data: {
          'workflow_id': workflowId,
          'prompt': prompt,
          'files': files
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('워크플로우 실행 실패: $e');
    }
  }

  Future<Map<String, dynamic>> _getStatus(String workflowId, String runId) async {
    try {
      final response = await _dio.get('/workflows/$workflowId/runs/$runId');
      return response.data;
    } catch (e) {
      throw Exception('상태 확인 실패: $e');
    }
  }

  Future<Map<String, dynamic>> _pollStatus(
    String workflowId, 
    String runId, {
    int maxAttempts = 30, 
    int delay = 10000
  }) async {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final status = await _getStatus(workflowId, runId);
      debugPrint('[ComfyICU] 상태 확인 ${attempt + 1}: ${status['status']}');
      if (status['status'] == 'COMPLETED' || status['status'] == 'ERROR') {
        return status;
      }

      await Future.delayed(Duration(milliseconds: delay));
    }
    throw Exception('최대 시도 횟수 초과');
  }
}
