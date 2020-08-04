import 'package:flutter/material.dart';
import 'package:weather/model/weather.dart';
import 'package:weather/tool/palette.dart';

/// 天氣資訊卡牌
class WeatherInfoItem extends StatefulWidget {

  final WeatherInfo weatherInfo;
  final String district;

  const WeatherInfoItem({
    Key key,
    @required this.weatherInfo,
    this.district,
  }) : assert(weatherInfo != null),
       super(key: key);

  @override
  _WeatherInfoItemState createState() => _WeatherInfoItemState();
}

class _WeatherInfoItemState extends State<WeatherInfoItem> {

  String get _iconUrl {
    return "https://openweathermap.org/img/wn/${widget.weatherInfo.weatherIconUrl}@2x.png";
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 8.0, right: 16.0),
                child:
                widget.district != null ?
                Text(
                  widget.district,
                  style: TextStyle(fontSize: 18.0),
                  textScaleFactor: 1.0,
                ) :
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "${widget.weatherInfo.date}",
                      style: TextStyle(fontSize: 12.0),
                      textScaleFactor: 1.0,
                    ),
                    Divider(height: 6.0,),
                    Text(
                      "${widget.weatherInfo.time}",
                      style: TextStyle(fontSize: 18.0),
                      textScaleFactor: 1.0,
                    )
                  ],
                ),
              ),
              Text(
                widget.weatherInfo.weatherDesc,
                style: TextStyle(fontSize: 18.0),
                textScaleFactor: 1.0,
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Image.network(
                _iconUrl,
                width: 44.0,
                height: 44.0,
              ),
              Padding(
                padding: EdgeInsets.only(left: 16.0, right: 8.0),
                child: Text(
                  "${widget.weatherInfo.temp}˚",
                  style: TextStyle(
                      fontSize: 36.0,
                      fontWeight: FontWeight.bold
                  ),
                  textScaleFactor: 1.0,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
