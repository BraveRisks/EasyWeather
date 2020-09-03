import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weather/model/weather.dart';

class WeatherProvider with ChangeNotifier {

  /// 天氣資料
  Weather weather;

  /// 現在位置的MarkerId
  String _current = "CurrentPosition";

  Set<Marker> _markers;

  /// 現在位置及空氣品質指標集合
  Set<Marker> get markers => _markers;

  /// 是否第一次載入天氣資料，default = true
  bool isFirstLoading = true;
  
  /// 是否載入天氣資料中，default = true
  bool get isWeatherLoading => _isWeatherLoading;

  bool _isWeatherLoading = true;

  /// 是否載入空氣品質資料中，default = false
  bool get isAQILoading => _isAQILoading;

  bool _isAQILoading = false;

  WeatherProvider() {
    _markers = Set();
  }

  set isWeatherLoading(bool isLoading) {
    this._isWeatherLoading = isLoading;
    notifyListeners();
  }

  set isAQILoading(bool isLoading) {
    this._isAQILoading = isLoading;
    notifyListeners();
  }

  void addCurrentMarkerAndSetWeather(Marker marker, Weather weather) {
    if (isFirstLoading) { isFirstLoading = false; }

    if (_markers.isNotEmpty) {
      _markers.removeWhere((e) => e.markerId.value == _current);
    }
    _markers.add(marker);

    this.weather = weather;

    notifyListeners();
  }

  void addAQIMarkers(Set<Marker> markers) {
    if (_markers.isNotEmpty) {
      _markers.removeWhere((e) => e.markerId.value != _current);
    }
    _markers.addAll(markers);

    notifyListeners();
  }
}