import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

class RunwareService {
  final String _apiKey = 'mUupomybPRmwNrUjnb02Ch4wsbdvmTX4';
  final String _apiUrl = 'https://api.runware.ai/v1';
  final String _uuid = const Uuid().v4();

  Future<String> generateImage(String positiveprompt) async {

    final body = jsonEncode({
        "taskType": "imageInference",
        "taskUUID": _uuid,
        "positivePrompt": positiveprompt,
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
        "lora": [{
          "model": "civitai:180891@838667",
          "weight": 1
        }]
      });

    final bodyBytes = utf8.encode(body);
    final contentLength = bodyBytes.length;

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
        'Content-Length': contentLength.toString(),
      },
      body: body,
    );
    debugPrint('response.body: ${response.body}');
    int res = response.statusCode;
    debugPrint("✅ 이미지 생성 프로세스! - $res");
    if (response.statusCode == 200) {
      debugPrint("✅ 이미지 생성 성공!");
      return response.body;
    } else {
      debugPrint("❌ 이미지 생성 실패!");
      throw Exception('Failed to generate image');
    }
  }
}
