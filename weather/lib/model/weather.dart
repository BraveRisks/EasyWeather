import 'package:intl/intl.dart';

class Weather {

  /// 時區
  String timezone;

  /// 時間間隔
  int timezoneOffset;

  WeatherInfo current;

  List<WeatherInfo> datas;

  Weather();

  Weather.fromJSON(Map<String, dynamic> map) {
    timezone = map["timezone"];
    timezoneOffset = map["timezoneOffset"];
    current = WeatherInfo.fromJSON(map["current"]);

    datas = List();
    final int length = (map["hourly"] as List).length;

    for (var i = 0; i < length; i++) {
      final info = WeatherInfo.fromJSON(map["hourly"][i]);
      datas.add(info);
    }
  }
}

class WeatherInfo {

  String date;

  String time;

  int sunrise;

  int sunset;

  int temp;

  double feelsLike;

  int pressure;

  int humidity;

  double uvi;

  int clouds;

  int visibility;

  double windSpeed;

  int windDeg;

  int weatherId;

  String weatherMain;

  String weatherDesc;

  String weatherIconUrl;

  WeatherInfo();

  WeatherInfo.fromJSON(Map<String, dynamic> map) {
    try {
      DateTime now = DateTime.fromMillisecondsSinceEpoch((map["dt"] as int) * 1000, isUtc: false);
      date = DateFormat("yyyy-MM-dd").format(now);
      time = DateFormat("HH:mm").format(now);

      sunrise = map["sunrise"];
      sunset = map["sunset"];

      if (map["temp"] is int) {
        temp = map["temp"];
      } else if (map["temp"] is double) {
        temp = (map["temp"] as double).round();
      }

      if (map["feels_like"] is int) {
        feelsLike = (map["feels_like"] as int).roundToDouble();
      } else if (map["feels_like"] is double) {
        feelsLike = map["feels_like"];
      }

      pressure = map["pressure"];
      humidity = map["humidity"];

      if (map["uvi"] is int) {
        uvi = (map["uvi"] as int).roundToDouble();
      } else if (map["uvi"] is double) {
        uvi = map["uvi"];
      }

      clouds = map["clouds"];
      visibility = map["visibility"];

      if (map["wind_speed"] is int) {
        windSpeed = (map["wind_speed"] as int).roundToDouble();
      } else if (map["wind_speed"] is double) {
        windSpeed = map["wind_speed"];
      }

      windDeg = map["wind_deg"];

      // info
      int length = (map["weather"] as List).length;
      weatherId = map["weather"][length - 1]["id"];
      weatherMain = map["weather"][length - 1]["main"];
      weatherDesc = map["weather"][length - 1]["description"];
      weatherIconUrl = map["weather"][length - 1]["icon"];
    } catch (e) {
      print("Error = ${e.toString()}");
    }
  }
}