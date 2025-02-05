import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
class WeatherApiService {

  Future<http.Response> fetchWeather(double lat, double lon) async {
    final response = await http.get(Uri.parse(
      'https://api.open-meteo.com/v1/forecast?'
      'latitude=$lat&longitude=$lon'
      '&current=temperature_2m,weathercode,windspeed_10m'
      '&hourly=temperature_2m,weathercode,windspeed_10m'
      '&daily=temperature_2m_max,temperature_2m_min,weathercode,windspeed_10m_max'
      '&timezone=auto'
      '&language=ko'
    ));
    if (response.statusCode == 200) {
      debugPrint('succeeded to fetch [weather data] from api');
      return response;
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }

}