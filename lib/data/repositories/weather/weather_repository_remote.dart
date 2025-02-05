import 'package:weathercloset/data/services/weatherapi_service.dart';
import 'package:weathercloset/domain/models/weather/weather_model.dart';
import 'package:weathercloset/data/repositories/weather/weather_repository.dart';
import 'package:weathercloset/data/services/geolocator_service.dart';
import 'package:weathercloset/domain/models/weather/location_model.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
class WeatherRepositoryRemote extends WeatherRepository {
  final WeatherApiService _weatherApiService;
  final GeolocatorService _geolocatorService;

  WeatherRepositoryRemote({
    required WeatherApiService weatherApiService,
    required GeolocatorService geolocatorService,
  }) : _weatherApiService = weatherApiService,
       _geolocatorService = geolocatorService;

  @override
  Stream<WeatherModel> watchWeather() {
  return _geolocatorService
    .watchLocation()
    .asyncMap((position) async {  // asyncMap 사용하여 
      final response = await _weatherApiService.fetchWeather(
        position.latitude,
        position.longitude
      );
      final weatherData = jsonDecode(response.body);
      _debugWeatherData(weatherData);
      return WeatherModel(weatherData);
    });
}

  @override
  Future<LocationModel> getCurrentLocation() async {
    final position = await _geolocatorService.getCurrentLocation();
    return LocationModel(position.latitude, position.longitude);
  }

    void _debugWeatherData(Map<String, dynamic> data) {
    debugPrint('\n=== Weather Data Debug ===');
    debugPrint('Current:');
    debugPrint('  Temperature: ${data['current']['temperature_2m']}');
    debugPrint('  WeatherCode: ${data['current']['weathercode']}');
    debugPrint('  WindSpeed: ${data['current']['windspeed_10m']}');
    
    debugPrint('\nHourly (first 3 entries):');
    for (var i = 0; i < 3; i++) {
      debugPrint('  ${data['hourly']['time'][i]}: '
          '${data['hourly']['temperature_2m'][i]}°C, '
          'Code: ${data['hourly']['weathercode'][i]}, '
          'Wind: ${data['hourly']['windspeed_10m'][i]}');
    }
    
    debugPrint('\nDaily (first 3 days):');
    for (var i = 0; i < 3; i++) {
      debugPrint('  ${data['daily']['time'][i]}: '
          'Max: ${data['daily']['temperature_2m_max'][i]}°C, '
          'Min: ${data['daily']['temperature_2m_min'][i]}°C');
    }
    debugPrint('========================\n');
  }
}