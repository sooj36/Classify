import 'package:flutter/material.dart';
import 'package:weathercloset/data/repositories/weather/weather_repository_remote.dart';
import 'package:weathercloset/domain/models/weather/weather_model.dart';

class CoordiViewModel extends ChangeNotifier {
  final WeatherRepositoryRemote _weatherRepositoryRemote;
  Stream<WeatherModel> _weatherStream;
  bool _isLoading;
  String? _error;

  CoordiViewModel({
    required WeatherRepositoryRemote weatherRepositoryRemote,
  }) : _weatherRepositoryRemote = weatherRepositoryRemote,
  _weatherStream = weatherRepositoryRemote.watchWeather(),
  _isLoading = false,
  _error = null;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Stream<WeatherModel> get weatherStream => _weatherStream;

  Future<void> fetchWeather() async {
    try {
      _isLoading = true;
      _weatherStream = _weatherRepositoryRemote.watchWeather();
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