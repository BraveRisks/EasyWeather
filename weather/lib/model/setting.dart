import 'package:flutter/cupertino.dart';
import 'package:package_info/package_info.dart';
import 'package:weather/tool/images.dart';

enum SettingType {

  api,

  aqi,

  version,

  mapStyle,

  none
}

/// 設定頁面 Model
class Setting {

  SettingType type;
  String title;
  Widget image;

  Setting(this.type) {
    title = _convertToTitle(type);
    image = _convertToImage(type);

    if (type == SettingType.version) {
      PackageInfo.fromPlatform().then((info) {
        title = "版本：${info.version}";
      });
    }
  }

  /// 將SettingType轉換為對應標題
  String _convertToTitle(SettingType type) {
    switch (type) {
      case SettingType.aqi:
        return "環境保護署";
      case SettingType.api:
        return "OpenWeather";
      default:
        return "";
    }
  }

  Widget _convertToImage(SettingType type) {
    switch (type) {
      case SettingType.aqi:
      case SettingType.api:
        return Images.icApiBlue;
      case SettingType.version:
        return Images.icVersionBlue;
      default:
        return null;
    }
  }

  void darkMode(bool isDark) {
    if (type != SettingType.mapStyle) { return; }

    title = "地圖風格：${isDark ? "深色" : "淺色"}";
    image = isDark ? Images.icNightBlue : Images.icDayBlue;
  }
}

