import 'package:flutter/material.dart';
import '../view_models/coordi_viewmodel.dart';
import '../../../../domain/models/weather/weather_model.dart';

class CoordinatorScreen extends StatefulWidget {
  final CoordiViewModel _coordiViewModel;

  const CoordinatorScreen({super.key,
  required CoordiViewModel coordiViewModel,
  }) : _coordiViewModel = coordiViewModel;

  @override
  State<CoordinatorScreen> createState() => _CoordinatorScreenState();
}

class _CoordinatorScreenState extends State<CoordinatorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget._coordiViewModel.fetchWeatherAndClothes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: widget._coordiViewModel,
        builder: (context, _) {
          if (widget._coordiViewModel.error != null) {
            return Center(child: Text('에러 발생: ${widget._coordiViewModel.error}'));
          }
          if (widget._coordiViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (widget._coordiViewModel.cachedWeather == null) {
            return const Center(child: Text('날씨 데이터가 없습니다'));
          }
          return Column(
              children: [
                weatherDataArea(widget._coordiViewModel.cachedWeather),
                coordiResponseArea(widget._coordiViewModel),
                requestCoordiButton(widget._coordiViewModel),
              ]
            );
        },
      ),
    );
  }

  Column weatherDataArea(WeatherModel? weather) {
    if (weather == null) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('날씨 데이터가 없습니다'),
        ],
      );
    }
    return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Table(
                  border: TableBorder.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            '구분',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            '현재 날씨',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            '온도',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            '${weather.weatherData['current']['temperature_2m']}°C',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            '풍속',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            '${weather.weatherData['current']['windspeed_10m']}m/s',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            '날씨',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _getWeatherDescription(weather.weatherData['current']['weathercode']),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
  }

  String _getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return '맑음';
      case 1:
      case 2:
      case 3:
        return '구름 있음';
      case 45:
      case 48:
        return '안개';
      case 51:
      case 53:
      case 55:
        return '이슬비';
      case 61:
      case 63:
      case 65:
        return '비';
      case 71:
      case 73:
      case 75:
        return '눈';
      case 77:
        return '싸락눈';
      case 80:
      case 81:
      case 82:
        return '소나기';
      case 85:
      case 86:
        return '눈소나기';
      case 95:
        return '천둥번개';
      default:
        return '알 수 없음';
    }
  }

  Text coordiResponseArea(CoordiViewModel viewModel) {
    return Text(viewModel.coordiResponse);
  }

  ElevatedButton requestCoordiButton(CoordiViewModel viewModel) {
    return ElevatedButton(
      onPressed: () {
        debugPrint('✅ 코디 요청 버튼 클릭');
        viewModel.requestCoordi();
        debugPrint('✅ 코디 요청 완료');
      },
      child: const Text('코디 요청', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }

  
}