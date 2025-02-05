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
    widget._coordiViewModel.fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<WeatherModel>(
        stream: widget._coordiViewModel.weatherStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('에러 발생: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('데이터가 없습니다'));
          }
          final weather = snapshot.data!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("현재 온도: ${weather.weatherData['current']['temperature_2m']}"),
                Text("현재 바람: ${weather.weatherData['current']['windspeed_10m']}"),
                Text("현재 날씨: ${weather.weatherData['current']['weathercode']}"),
              ],
            ),
          );
        },
      ),
    );
  }
}