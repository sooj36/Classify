import 'package:flutter/material.dart';
import 'package:weathercloset/data/repositories/weather/weather_repository_remote.dart';
import 'package:weathercloset/data/repositories/cloth_analyze/cloth_repository_remote.dart';
import 'package:weathercloset/domain/models/weather/weather_model.dart';
import 'package:weathercloset/domain/models/cloth/cloth_model.dart';

//StreamBuilder를 사용하지 않고 데이터를 캐시하여 사용하였음
//화면을 전환하면 Stream으로부터 새 데이터가 오기 전까지는 데이터를 표시하지 않기 때문
class CoordiViewModel extends ChangeNotifier {
  final WeatherRepositoryRemote _weatherRepositoryRemote;
  final ClothRepositoryRemote _clothRepositoryRemote;
  late Stream<WeatherModel> _weatherStream;
  late Stream<Map<String, ClothModel>> _clothesStream;
  WeatherModel? _cachedWeather;
  Map<String, ClothModel>? _cachedClothes;
  List<ClothModel>? _coordiClothes;
  bool _isLoading;
  String _coordiResponse;
  String _coordiTexts;

  String? _error;

  CoordiViewModel({
    required WeatherRepositoryRemote weatherRepositoryRemote,
    required ClothRepositoryRemote clothRepositoryRemote,
  }) : _weatherRepositoryRemote = weatherRepositoryRemote,
  _clothRepositoryRemote = clothRepositoryRemote,
  _isLoading = false,
  _coordiResponse = "",
  _coordiClothes = [],
  _coordiTexts = "",
  _error = null;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Stream<WeatherModel> get weatherStream => _weatherStream;
  String get coordiResponse => _coordiResponse;
  WeatherModel? get cachedWeather => _cachedWeather;
  Map<String, ClothModel>? get cachedClothes => _cachedClothes;
  List<ClothModel>? get coordiClothes => _coordiClothes;
  String get coordiTexts => _coordiTexts;
  Future<void> fetchWeatherAndClothes() async {
    try {
      _isLoading = true;
      notifyListeners();
      //stream은 기본적으로 single-subscription이므로 코디 요청을 보낼 때 필요한 데이터를 캐시
      _weatherStream = _weatherRepositoryRemote.watchWeather();
      _weatherStream.listen((weather) {
          _cachedWeather = weather;
          debugPrint('날씨 데이터 캐시 업데이트됨');
          notifyListeners(); //중요! - listen 함수는 콜백 함수이기 때문에 반드시 필요
        });      
      _clothesStream = _clothRepositoryRemote.watchClothLocal();
      _clothesStream.listen((clothes) {
          _cachedClothes = clothes;
          debugPrint('옷장 데이터 캐시 업데이트됨');
          notifyListeners();
      });
      _isLoading = false;
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
      // 옷 데이터를 리스트로 변환
      final clothesList = _cachedClothes!.entries.map((entry) => {
        "id": entry.key,
        "대분류": entry.value.major,
        "소분류": entry.value.minor,
        "색깔": entry.value.color,
        "재질": entry.value.material,
      }).toList();
      debugPrint('👕 옷 리스트: ${clothesList.map((cloth) => '\n${cloth.toString()}').join()}');

      // 최종 요청 데이터 구성
      return {
        "날씨": {
          "temperature": _cachedWeather!.weatherData["current"]["temperature_2m"],
          "weathercode": _cachedWeather!.weatherData["current"]["weathercode"],
          "windpseed": _cachedWeather!.weatherData["current"]["windspeed_10m"],
        },
        "옷장": clothesList,
        "요청": "오늘 날씨에 어떤 옷을 입을지 너무 고민됩니다. 그래서 세계 최고의 코디네이터인 당신에게 묻습니다. 당신은 특히나 여러 코디 배색 법칙을 활용한 색깔의 마술사라고도 불리는 천재입니다. 아래의 json 형식으로 입어야 할 옷들의 uuid와 왜 그렇게 입어야 하는지 이유를 50자 이내로 반환해주세요. 만약 내가 당신에게 보낸 옷 리스트만으로 최고의 코디를 만들 수 없다면 솔직하게 말해주고 어떤 옷이 있으면 좋을지 추천해주세요 그리고 적절한 이모티콘을 딱 하나만 활용해서 친절한 느낌으로 답변해주세요 그리고 json 형식이므로 모든 key와 모든 value가 각각 큰따옴표로 감싼 응답을 줘야 합니다. 마크다운의 코드블록으로 감싸지지 않은 순수한 문자열로 주세요.",
        "형식": {
          "uuid": {
            "id1": "string",
            "id2": "string",
            "id3": "string",
          },
          "이유": "string"
        }
      };
    } catch (e) {
      debugPrint('❌ 코디 요청 데이터 생성 실패: $e');
      throw Exception('코디 요청 데이터 생성 실패: $e');
    }
  }
  
  Future<void> requestCoordi() async {
    try {
      debugPrint('✅ 코디 요청 시작 - viewmodel');
      final request = await _createCoordiRequest();
      debugPrint('✅ 코디 요청 데이터 생성 완료 - viewmodel');
      _coordiResponse = await _clothRepositoryRemote.requestCoordi(request);
      debugPrint('👕 코디 요청 결과: $_coordiResponse');
      _coordiClothes = _clothRepositoryRemote.getCoordiClothes(_coordiResponse, _cachedClothes!);
      _coordiTexts = _clothRepositoryRemote.getCoordiTexts(_coordiResponse);
      debugPrint('👕 코디 옷 리스트: ${_coordiClothes!.map((cloth) => '\n${cloth.major}').join()}');
      debugPrint("코디 요청 결과: $_coordiResponse");
      debugPrint('✅ 코디 요청 완료 - viewmodel');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = "${e.toString()} $_coordiResponse";
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}