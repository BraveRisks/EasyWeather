import 'package:shared_preferences/shared_preferences.dart';

enum PrefsKey {
  isDarkMap
}

class PrefsManager {

  static final PrefsManager _instance = PrefsManager._internal();

  factory PrefsManager() => _instance;

  PrefsManager._internal();

  // 外部調用
  static PrefsManager get share => _instance;

  Future<bool> setValue(PrefsKey key, dynamic value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    if (value is bool) {
      return preferences.setBool(convert(key), value);
    } else if (value is int) {
      return preferences.setInt(convert(key), value);
    } else if (value is double) {
      return preferences.setDouble(convert(key), value);
    } else if (value is String) {
      return preferences.setString(convert(key), value);
    } else if (value is List<String>) {
      return preferences.setStringList(convert(key), value);
    }

    return false;
  }

  Future<dynamic> getValue(PrefsKey key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    return preferences.get(convert(key));
  }

  /// 將`PrefsKey`轉為對應的key
  String convert(PrefsKey key) {
    switch (key) {
      case PrefsKey.isDarkMap:
        return "isDarkMap";
      default:
        return "";
    }
  }
}