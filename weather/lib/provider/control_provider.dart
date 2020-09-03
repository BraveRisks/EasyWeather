import 'package:flutter/material.dart';
import 'package:weather/tool/PrefsManager.dart';

enum ChangeType {
  weatherList, darkMap
}

class CtrlProvider with ChangeNotifier {

  /// 是否為深色樣式地圖
  bool get isDarkMap => _isDarkMap;

  bool _isDarkMap = false;

  /// 是否顯示天氣列表
  bool get showWeatherList => _showWeatherList ;

  bool _showWeatherList = false;

  // ignore: missing_return
  Future<bool> change(ChangeType type, {bool value}) async {
    switch (type) {
      case ChangeType.darkMap:
        // 如果有給予初始值，則就不做儲存動作
        if (value != null) {
          _isDarkMap = value;
        } else {
          _isDarkMap = !_isDarkMap;

          PrefsManager.share.setValue(PrefsKey.isDarkMap, isDarkMap);
        }
        break;
      case ChangeType.weatherList:
        _showWeatherList = !_showWeatherList;
        break;
    }

    notifyListeners();

    switch (type) {
      case ChangeType.darkMap:
        return _isDarkMap;
      case ChangeType.weatherList:
        return _showWeatherList;
    }
  }
}