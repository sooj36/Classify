import 'package:flutter/material.dart';
import 'package:weathercloset/data/repositories/weather/weather_repository_remote.dart';
import 'package:weathercloset/data/repositories/cloth_analyze/cloth_repository_remote.dart';
import 'package:weathercloset/domain/models/weather/weather_model.dart';
import 'package:weathercloset/domain/models/cloth/cloth_model.dart';
class CoordiViewModel extends ChangeNotifier {
  final WeatherRepositoryRemote _weatherRepositoryRemote;
  final ClothRepositoryRemote _clothRepositoryRemote;
  late Stream<WeatherModel> _weatherStream;
  late Stream<Map<String, ClothModel>> _clothesStream;
  bool _isLoading;
  String _coordiResponse;

  String? _error;

  CoordiViewModel({
    required WeatherRepositoryRemote weatherRepositoryRemote,
    required ClothRepositoryRemote clothRepositoryRemote,
  }) : _weatherRepositoryRemote = weatherRepositoryRemote,
  _clothRepositoryRemote = clothRepositoryRemote,
  _isLoading = false,
  _coordiResponse = "",
  _error = null;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Stream<WeatherModel> get weatherStream => _weatherStream;
  String get coordiResponse => _coordiResponse;
  Future<void> fetchWeatherAndClothes() async {
    try {
      _isLoading = true;
      _weatherStream = _weatherRepositoryRemote.watchWeather();

      _clothesStream = _clothRepositoryRemote.watchClothLocal();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> _createCoordiRequest() async {
    try {
      // 최신 날씨와 옷 데이터 가져오기
      final latestWeather = await _weatherStream.first;
      final latestClothes = await _clothesStream.first;
      debugPrint('✅ 최신 날씨와 옷 데이터 가져오기 완료 - viewmodel');

      // 옷 데이터를 리스트로 변환
      final clothesList = latestClothes.entries.map((entry) => {
        "id": entry.key,
        "대분류": entry.value.major,
        "소분류": entry.value.minor,
        "색깔": entry.value.color,
        "재질": entry.value.material,
      }).toList();

      // 최종 요청 데이터 구성
      return {
        "날씨": {
          "온도": latestWeather.weatherData["current"]["temperature_2m"],
          "날씨": latestWeather.weatherData["current"]["weathercode"],
          "강수확률": latestWeather.weatherData["current"]["windspeed_10m"],
        },
        "옷장": clothesList,
        "요청": "오늘 날씨에 어떤 옷을 입을까? 아래의 json 형식으로 입어야 할 옷들의 uuid와 왜 그렇게 입어야 하는지 이유를 반환해줘",
        "형식": {
          "uuid": {
            "uuid": "string, string, string, string",
          },
          "이유": "string"
        }
      };
    } catch (e) {

      // debugPrint('❌ 코디 요청 데이터 생성 실패: $e');
      throw Exception('코디 요청 데이터 생성 실패: $e');
    }
  }
  
  Future<void> requestCoordi() async {
    try {
      debugPrint('✅ 코디 요청 시작 - viewmodel');
      final request = await _createCoordiRequest();
      debugPrint('✅ 코디 요청 데이터 생성 완료 - viewmodel');
      _coordiResponse = await _clothRepositoryRemote.requestCoordi(request);
      debugPrint('✅ 코디 요청 완료 - viewmodel');
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}