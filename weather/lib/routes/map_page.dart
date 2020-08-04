import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:weather/model/setting.dart';
import 'package:weather/model/weather.dart';
import 'package:weather/network/api-manager.dart';
import 'package:weather/provider/dark_mode_provider.dart';
import 'package:weather/provider/weather_provider.dart';
import 'package:weather/tool/images.dart';

import 'package:weather/tool/palette.dart';
import 'package:weather/transition/weatherInfo_list_height_transition.dart';
import 'package:weather/widgets/weather_info_item.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {

  const MapPage({Key key}): super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

/// Reference: https://www.digitalocean.com/community/tutorials/flutter-geolocator-plugin#getting-the-current-location
class _MapPageState extends State<MapPage> with TickerProviderStateMixin {

  GoogleMapController _mapController;

  /// 地圖樣式
  String _mapStyle;

  /// 地圖圖標
  BitmapDescriptor _pinIcon;

  /// 天氣 Model
  Weather _weather;

  /// 是否顯示天氣列表，default = false
  bool _isShowList = false;
  
  /// 是否為深色模式，default = false
  //bool _isDark = false;
  
  /// 螢幕寬度
  double _screenW;

  /// 動畫
  AnimationController _animationController;
  Animation<double> _animation;

  /// Scroll Controller
  ScrollController _scrollController;

  /// 定位
  Geolocator _geolocator;

  /// 目前位置
  LatLng _current;

  /// 目前行政區
  String _district;

  /// 預設位置：台北101
  final LatLng _default = LatLng(25.033678, 121.565086);

  final ApiManager _apiManager = ApiManager.share;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = new Tween(begin: 0.0, end: 330.0)
      .animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn
    ));

    _scrollController = ScrollController();

    _loadMapAssets();

    _geolocator = Geolocator()..forceAndroidLocationManager = true;

    // 基本上第一次開啟App時，會是'unknow'，等到使用者選擇後，才會是'denied' or 'granted'
    _geolocator.checkGeolocationPermissionStatus().then((status) {
        switch (status) {
          case GeolocationStatus.unknown:
            print("Location unknown");
            break;
          case GeolocationStatus.denied:
            print("Location denied");
            break;
          case GeolocationStatus.disabled:
            print("Location disabled");
            break;
          case GeolocationStatus.granted:
            print("Location granted");
            break;
          case GeolocationStatus.restricted:
            print("Location restricted");
            break;
        }
    });

    // 該function會等到使用者選擇後才進行
    _geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
          print("Current = ${position.latitude}, ${position.longitude}");
          _current = LatLng(position.latitude, position.longitude);
    }).catchError((e) {
      print("Error");
    }).whenComplete(() {
      print("Complete");

      Provider.of<WeatherProvider>(context, listen: false)
              .fetchWeatherBy(_current ?? _default, _geolocator);
    });
  }

  @override
  Widget build(BuildContext context) {
    _screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          map(context),
          weatherInfoItem(context),
          weatherInfoList(context),
          darkModeButton(context),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget weatherInfoItem(BuildContext context) {
    final padding = 16.0;

    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.only(
          left: padding,
          top: MediaQuery.of(context).padding.top + 10.0,
          right: padding
        ),
        child: Container(
          width: _screenW - (padding * 2),
          height: 60.0,
          decoration: BoxDecoration(
            border: Border.all(
              style: BorderStyle.none
            ),
            borderRadius: BorderRadius.circular(8.0),
            color: Color(0xd9f2f2f2)
          ),
          child: Consumer<WeatherProvider>(
            builder: (context, provider, child) {
              return provider.weather == null ?
              progress() :
              WeatherInfoItem(
                district: provider.district ?? "",
                weatherInfo: provider.weather.current,
              );
            },
          )
        ),
      ),
      onTap: () => _showOrHideList(tapFromMap: false),
    );
  }

  GoogleMap map(BuildContext context) {
    WeatherProvider provider = Provider.of<WeatherProvider>(context);

    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _current ?? _default,
        zoom: 13.0
      ),
      markers: provider.weather == null ?
      null :
      {
        Marker(
          markerId: MarkerId("111"),
          icon: _pinIcon,
          position: _current ?? _default,
          draggable: true,
          flat: false,
          consumeTapEvents: false,
          onDragEnd: (position) {
            _mapController.animateCamera(CameraUpdate.newLatLng(position));

            _current = LatLng(position.latitude, position.longitude);
            Provider.of<WeatherProvider>(context, listen: false)
                    .fetchWeatherBy(_current ?? _default, _geolocator);
          }
        )
      },
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      onTap: (LatLng latLng) => _showOrHideList(tapFromMap: true),
    );
  }

  Widget weatherInfoList(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: WeatherInfoListHeightTransition(
        animation: _animation,
        child: Consumer<WeatherProvider>(
          builder: (context, provider, child) =>
              ListView.builder(
              padding: EdgeInsets.zero,
              controller: _scrollController,
              itemCount: provider.weather == null ? 0 : provider.weather.datas.length,
              itemBuilder: (context, position) {
                return Container(
                  width: _screenW,
                  height: 70.0,
                  child: WeatherInfoItem(
                    weatherInfo: provider.weather.datas[position],
                  ),
                );
              }
          ),
        ),
      ),
    );
  }

  Widget progress() {
    final Size size = Size(30.0, 30.0);

    return Center(
      child: Container(
        width: size.width,
        height: size.height,
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Palette.on699ad0),
        ),
      ),
    );
  }
  
  Widget darkModeButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: EdgeInsets.only(bottom: 32.0, right: 24.0),
        child: GestureDetector(
          child: Container(
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              border: Border.all(
                  style: BorderStyle.none
              ),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 0.0,
                    blurRadius: 8.0,
                    offset: Offset(0.0, 2.0)
                )
              ],
            ),
            child: Consumer<DarkMode>(
              builder: (context, darkMode, child) {
                _mapController?.setMapStyle(darkMode.isDark ? _mapStyle : null);
                return darkMode.isDark ? Images.icDay : Images.icNight;
              },
            ),
          ),
          onTap: () {
            Provider.of<DarkMode>(context, listen: false).change();
          },
        ),
      ),
    );
  }

  void _loadMapAssets() async {
    _mapStyle = await rootBundle.loadString("resource/map_night_style.txt");
    _pinIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(),
        Images.icPinBlueStr
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _showOrHideList({@required bool tapFromMap}) {
    // 如果從地圖點擊且列表未顯示，就返回
    if (tapFromMap && _isShowList == false) {
      return;
    }

    setState(() {
      _isShowList = !_isShowList;

      if (_isShowList) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }
}