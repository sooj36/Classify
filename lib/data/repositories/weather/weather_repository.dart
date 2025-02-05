import 'package:weathercloset/domain/models/weather/weather_model.dart';
import 'package:weathercloset/domain/models/weather/location_model.dart';
import 'package:flutter/material.dart';

abstract class WeatherRepository extends ChangeNotifier {

  Stream<WeatherModel> watchWeather();

  Future<LocationModel> getCurrentLocation();
}