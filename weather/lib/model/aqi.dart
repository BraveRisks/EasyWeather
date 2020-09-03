import 'dart:ui';

import 'package:weather/tool/palette.dart';
import 'package:weather/extension/extension-string.dart';

enum Region {

  /// 北部
  north,

  /// 中部
  central,

  /// 南部
  south,

  /// 東部
  east,

  /// 外離島
  outerIsland
}

class AQI {

  /// 觀測站編號
  String siteId;

  /// 觀測站名稱
  String siteName;

  /// 縣市
  String county;

  /// 空氣品質指標
  String aqi;

  /// 空氣污染物指標
  String pollutant;

  /// 狀態
  String status;

  /// 二氧化硫(ppb)
  String so2;

  /// 一氧化碳(ppm)
  String co;

  /// 一氧化碳8小時移動平均(ppm)
  String co_8hr;

  /// 臭氧(ppb)
  String o3;

  /// 臭氧8小時移動平均(ppb)
  String o3_8hr;

  /// 懸浮微粒(μg/m3)
  String pm10;

  /// 細懸浮微粒(μg/m3)
  String pm2p5;

  /// 二氧化氮(ppb)
  String no2;

  /// 氮氧化物(ppb)
  String nox;

  /// 一氧化氮(ppb)
  String no;

  /// 風速(m/sec)
  String windSpeed;

  /// 風向(degrees)
  String windDirec;

  /// 資料建置日期
  String publishTime;

  /// 細懸浮微粒移動平均值(μg/m3)
  String pm2p5_AVG;

  /// 懸浮微粒移動平均值(μg/m3)
  String pm10_AVG;

  /// 二氧化硫移動平均值(ppb)
  String so2_AVG;

  /// 經度
  String longitude;

  /// 緯度
  String latitude;

  /// 區域
  Region region;

  /// 主題色
  Color themeColor;

  /// AQI數值對應顏色
  Color aqiColor;

  AQI();

  AQI.fromJSON(Map<String, dynamic> map) {
    siteId = map["SiteId"];
    siteName = map["SiteName"];
    county = map["County"];
    aqi = map["AQI"];
    pollutant = map["Pollutant"];
    status = map["Status"];
    so2 = map["SO2"];
    co = map["CO"];
    co_8hr = map["CO_8hr"];
    o3 = map["O3"];
    o3_8hr = map["O3_8hr"];
    pm10 = map["PM10"];
    pm2p5 = map["PM2.5"];
    no2 = map["NO2"];
    nox = map["NOx"];
    no = map["NO"];
    windSpeed = map["WindSpeed"];
    windDirec = map["WindDirec"];
    publishTime = map["PublishTime"];
    pm2p5_AVG = map["PM2.5_AVG"];
    pm10_AVG = map["PM10_AVG"];
    so2_AVG = map["SO2_AVG"];
    longitude = map["Longitude"];
    latitude = map["Latitude"];

    int aqiValue = aqi.intIfNullOrEmpty(to: 0);

    if (aqiValue <= 50) {
      aqiColor = Palette.on159868;
    } else if (aqiValue > 50 && aqiValue <= 100) {
      aqiColor = Palette.onfff962;
    } else if (aqiValue > 100 && aqiValue <= 150) {
      aqiColor = Palette.onfd9941;
    } else if (aqiValue > 150 && aqiValue <= 200) {
      aqiColor = Palette.onfb0d1b;
    } else if (aqiValue > 200 && aqiValue <= 300) {
      aqiColor = Palette.on981497;
    } else {
      aqiColor = Palette.on97050b;
    }

    switch (county) {
      case "臺北市":
      case "新北市":
      case "基隆市":
      case "桃園市":
      case "新竹縣":
      case "新竹市":
        region = Region.north;
        themeColor = Palette.onfc5457;
        break;
      case "苗栗縣":
      case "臺中市":
      case "彰化縣":
      case "南投縣":
      case "雲林縣":
        region = Region.central;
        themeColor = Palette.on525afb;
        break;
      case "嘉義縣":
      case "嘉義市":
      case "臺南市":
      case "高雄市":
      case "屏東縣":
        region = Region.south;
        themeColor = Palette.on59d5fd;
        break;
      case "宜蘭縣":
      case "花蓮縣":
      case "臺東縣":
        region = Region.east;
        themeColor = Palette.onfda75a;
        break;
      case "澎湖縣":
      case "連江縣":
      case "金門縣":
        region = Region.outerIsland;
        themeColor = Palette.ond5fd60;
        break;
      default:
        region = Region.north;
        themeColor = Palette.onfc5457;
        break;
    }
  }
}