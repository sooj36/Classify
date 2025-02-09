import 'package:flutter/material.dart';
import '../view_models/coordi_viewmodel.dart';
import '../../../../domain/models/weather/weather_model.dart';
import 'dart:io';
import '../../../../domain/models/cloth/cloth_model.dart';

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
          debugPrint('👕 코디 텍스트: ${widget._coordiViewModel.coordiTexts}');
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                weatherDataArea(widget._coordiViewModel.cachedWeather),
                coordiResponseArea(widget._coordiViewModel),
                coordiTextArea(widget._coordiViewModel),
                requestCoordiButton(widget._coordiViewModel),
              ],
            ),
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

  Expanded coordiResponseArea(CoordiViewModel viewModel) {
    return Expanded(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: viewModel.coordiClothes!.length,
          itemBuilder: (context, index) {
          debugPrint('👕 코디 옷 리스트 작성 시작: ${viewModel.coordiClothes!.map((cloth) => '\n${cloth.major}').join()}');
          final cloth = viewModel.coordiClothes![index];
          return SizedBox(
            width: 130,
            child: individualCards(cloth),
          );
        },
      ),
    );  
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

  Card individualCards(cloth) {
  debugPrint('👕 개별 카드 작성 시작: ${cloth.major}');
  return Card(
    clipBehavior: Clip.antiAlias,
    child: SizedBox(  // 고정된 크기 지정
      height: 70,    // 카드의 높이 지정
      child: Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Expanded(   
      flex: 3,  // 이미지 영역이 더 크게
      child: _buildClothImage(cloth),
    ),
    Expanded(   
      flex: 1,  // 텍스트 영역이 더 작게
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Text(
              cloth.minor ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    ),
  ],
),
    ),
  );
}

  Widget _buildClothImage(ClothModel cloth) {
    return cloth.localImagePath != null
      ? Image.file(
          File(cloth.localImagePath!),
          fit: BoxFit.cover,
        )
      : Container(
          color: Colors.grey[200],
            child: const Icon(Icons.image, size: 40),
          );
  }

  Widget coordiTextArea(CoordiViewModel viewModel) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: viewModel.coordiTexts.isEmpty ? 0.0 : 1.0,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.amber),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                viewModel.coordiTexts,
                key: ValueKey(viewModel.coordiTexts),
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }


}