import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:weather/model/aqi.dart';
import 'package:weather/model/weather.dart';
import 'package:weather/network/api-manager.dart';
import 'package:weather/provider/control_provider.dart';
import 'package:weather/provider/weather_provider.dart';
import 'package:weather/tool/PrefsManager.dart';
import 'package:weather/tool/images.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weather/tool/palette.dart';
import 'package:weather/transition/weatherInfo_list_height_transition.dart';
import 'package:weather/widgets/circle_shadow_button.dart';
import 'package:weather/widgets/weather_info_item.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/extension/extension-string.dart';

class MapPage extends StatefulWidget {

  const MapPage({Key key}): super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

/// Reference: https://www.digitalocean.com/community/tutorials/flutter-geolocator-plugin#getting-the-current-location
class _MapPageState extends State<MapPage> with TickerProviderStateMixin {

  GoogleMapController _mapController;

  /// 地圖樣式
  String _mapDarkStyle;

  /// 行政區
  String district;

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

  /// 儲存AQI 位置
  Set<Marker> aqiMarkers = Set();

  /// 預設位置：台北101
  final LatLng _default = LatLng(25.033678, 121.565086);

  ApiManager _apiManager = ApiManager.share;

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
      print("Error = $e");
    }).whenComplete(() {
      print("Complete");
      _fetchWeather(_current ?? _default);
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
          menuButtons(context),
          weatherInfoList(context),
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
              return provider.isWeatherLoading ?
              progress() :
              WeatherInfoItem(
                district: district ?? "",
                weatherInfo: provider.weather.current,
              );
            },
          )
        ),
      ),
      onTap: () => _showOrHideList(tapFromMap: false),
    );
  }

  Widget progress({Size size = const Size(30.0, 30.0)}) {
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

  GoogleMap map(BuildContext context) {
    WeatherProvider provider = Provider.of<WeatherProvider>(context);

    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _current ?? _default,
        zoom: 13.0
      ),
      markers: provider.isFirstLoading ? null : provider.markers,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
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
              itemCount: provider.isFirstLoading ? 0 : provider.weather.datas.length,
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
  
  Widget menuButtons(BuildContext context) {
    WeatherProvider provider = Provider.of<WeatherProvider>(context);

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: EdgeInsets.only(bottom: 32.0, right: 24.0),
        child: Container(
          width: 50.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              provider.isFirstLoading ?
              Divider(
                height: 0.0,
                color: Colors.transparent,
              ) :
              CircleShadowButton(
                height: 50.0,
                child: provider.isAQILoading ? progress(size: Size(24.0, 24.0)) : Images.icAqi,
                onTap: provider.isAQILoading ? null : _fetchAQI,
              ),
              Divider(
                height: 10.0,
                color: Colors.transparent,
              ),
              CircleShadowButton(
                height: 50.0,
                child: Consumer<CtrlProvider>(
                  builder: (context, provider, child) {
                    _mapController?.setMapStyle(provider.isDarkMap ? _mapDarkStyle : null);
                    return provider.isDarkMap ? Images.icDay : Images.icNight;
                  },
                ),
                onTap: () => Provider.of<CtrlProvider>(context, listen: false)
                    .change(ChangeType.darkMap),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _onMapCreated(GoogleMapController controller) async {
    _mapDarkStyle = await rootBundle.loadString("resource/map_night_style.txt");
    _mapController = controller;

    PrefsManager.share.getValue(PrefsKey.isDarkMap).then((value) {
      if (value != null && value is bool) {
        Provider.of<CtrlProvider>(context, listen: false)
            .change(ChangeType.darkMap, value: value);
      }
    });
  }

  void _showOrHideList({@required bool tapFromMap}) {
    CtrlProvider provider = Provider.of<CtrlProvider>(context, listen: false);
    
    // 如果從地圖點擊且列表未顯示，就返回
    if (tapFromMap && provider.showWeatherList == false) {
      return;
    }

    provider.change(ChangeType.weatherList).then((value) {
      if (value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _fetchWeather(LatLng position) async {
    // 移動至使用者當前的位置
    _mapController?.animateCamera(CameraUpdate.newLatLng(position));

    Provider.of<WeatherProvider>(context, listen: false).isWeatherLoading = true;

    // 取得經緯度對應的行政區
    _geolocator.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        localeIdentifier: "zh_TW"
    ).then((List<Placemark> places) {
      if (places.isNotEmpty) {
        district = places[0].locality;
      }
    }).catchError((e) {
      print("FromCoordinates error = $e");
    });

    BitmapDescriptor pinIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(
            devicePixelRatio: MediaQuery.of(context).devicePixelRatio
        ),
        Images.icPinStr
    );

    _apiManager.request(
        ApiPath.weather,
        {
          "exclude": "daily",
          "units": "metric",
          "lang": "zh_tw",
          "appid": "32be38731000e42f21c4a11e721f168f",
          "lat": "${position.latitude}",
          "lon" : "${position.longitude}"
        },
        debugPrintRequest: true,
        debugPrintResponse: false,
        onSuccess: (result) {
          // 新增目前位置Marker
          Marker marker = Marker(
            markerId: MarkerId("CurrentPosition"),
            position: position,
            icon: pinIcon,
            zIndex: 1.0,
            draggable: true,
            onDragEnd: (LatLng position) {
              _mapController.animateCamera(CameraUpdate.newLatLng(position));
              _current = LatLng(position.latitude, position.longitude);
              _fetchWeather(position);
            },
          );

          Provider.of<WeatherProvider>(context, listen: false)
              .addCurrentMarkerAndSetWeather(marker, Weather.fromJSON(result));
        },
        onDone: () => Provider.of<WeatherProvider>(context, listen: false).isWeatherLoading = false,
    );
  }

  /// 取得目前的空氣品質指標
  void _fetchAQI() async {
    final ratio = MediaQuery.of(context).devicePixelRatio;

    List<String> iconNames = [
      Images.icNorthStr, Images.icCentralStr, Images.icSouthStr,
      Images.icEastStr, Images.icOuterIslandStr
    ];

    List<BitmapDescriptor> icons = List();

    for (int i = 0; i < iconNames.length; i++) {
      icons.add(await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(devicePixelRatio: ratio),
          iconNames[i]
      ));
    }

    Provider.of<WeatherProvider>(context, listen: false).isAQILoading = true;

    ApiManager.share.request(
        ApiPath.aqi,
        {
          "limit": "200",
          "format": "json",
          "api_key": "305ec26d-bdc7-4ee4-9689-fbbb8f778406"
        },
        debugPrintResponse: false,
        onSuccess: (result) {
          if ((result["records"] is List) == false) { return; }

          List<AQI> datas = List();
          for (int i = 0; i < (result["records"] as List).length; i++) {
            datas.add(AQI.fromJSON(result["records"][i]));
          }

          Set<Marker> markers = Set();

          // 篩選站台ID不為空字串
          datas.where((e) => e.siteId.isNotEmpty).toList().forEach((aqi) {
            BitmapDescriptor icon;

            switch (aqi.region) {
              case Region.north:
                icon = icons[0];
                break;
              case Region.central:
                icon = icons[1];
                break;
              case Region.south:
                icon = icons[2];
                break;
              case Region.east:
                icon = icons[3];
                break;
              case Region.outerIsland:
                icon = icons[4];
                break;
            }

            markers.add(Marker(
              markerId: MarkerId(aqi.siteId),
              position: LatLng(aqi.latitude.toDouble(), aqi.longitude.toDouble()),
              icon: icon,
              onTap: () => _showAQIInfo(aqi),
            ));
          });

          Provider.of<WeatherProvider>(context, listen: false)
              .addAQIMarkers(markers);
        },
        onFailed: (error, description) {
          final snackBar = SnackBar(
            content: Text(
              "$description",
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: Palette.on979797,
              ),
            ),
            backgroundColor: Colors.white,
          );

          Scaffold.of(context).showSnackBar(snackBar);
        },
        onDone: () => Provider.of<WeatherProvider>(context, listen: false).isAQILoading = false,
    );
  }

  /// 顯示AQI資訊Dialog
  void _showAQIInfo(AQI aqi) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Container(
            width: 240.0,
            height: 410.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _dialogTitle(aqi),
                _dialogContent(aqi),
                _dialogList(aqi),
                _dialogUpdateTime(aqi),
              ],
            ),
          ),
        );
      }
    );
  }

  /// Dialog 標題
  Widget _dialogTitle(AQI aqi) {
    return Container(
      width: double.infinity,
      height: 56.0,
      decoration: BoxDecoration(
        color: aqi.themeColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0)
        ),
      ),
      child: Center(
        child: Text(
          "${aqi.county} ${aqi.siteName}",
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
            color: Colors.white
          ),
        ),
      ),
    );
  }

  /// Dialog AQI數值
  Widget _dialogContent(AQI aqi) {
    return Padding(
      padding: EdgeInsets.only(top: 22.0, bottom: 16.0),
      child: Container(
        width: 130.0,
        height: 130.0,
        decoration: BoxDecoration(
          border: Border.all(
            width: 4.0,
            color: aqi.aqiColor,
          ),
          borderRadius: BorderRadius.circular(65.0),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 12.0),
              child: Text(
                "空氣品質指標",
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                  color: Palette.on979797,
                  height: 1.0,
                ),
              ),
            ),// Padding
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                "${aqi.aqi}",
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w600,
                  color: Palette.on979797,
                  height: 1.0,
                ),
              ),
            ),// Padding
            Container(
              width: 80.0,
              child: Text(
                "${aqi.status}",
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                  color: Palette.on979797,
                  height: 1.0,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ),// Text
          ],
        ),
      ),
    );
  }

  /// Dialog List
  Widget _dialogList(AQI aqi) {
    List<String> titles = ["PM", "PM", "O", "CO", "SO", "NO"];
    List<String> subTitles = ["2.5", "10", "3", "", "2", "2"];
    List<String> values = [aqi.pm2p5, aqi.pm10, aqi.o3,
                           aqi.co, aqi.so2, aqi.no2];
    List<String> units = ["(ug/m3)", "(ug/m3)", "(ppb)", "(ppm)", "(ppm)", "(ppm)"];

    return Padding(
      padding: EdgeInsets.only(left: 30.0, bottom: 16.0, right: 30.0),
      child: Container(
        height: 144.0,
        child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: EdgeInsets.zero,
          itemCount: 6,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                height: 24.0,
                child: Row(
                  children: [
                    Text(
                      titles[index],
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),// Text
                    Text(
                      subTitles[index],
                      style: TextStyle(
                        fontSize: 8.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),// Text
                    Spacer(
                      flex: 1,
                    ),// Spacer
                    Text(
                      values[index],
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),// Text
                    Spacer(
                      flex: 1,
                    ),// Spacer
                    Text(
                      units[index],
                      style: TextStyle(
                        fontSize: 8.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),// Text
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Dialog Update Time
  Widget _dialogUpdateTime(AQI aqi) {
    return Text(
      "更新時間：${aqi.publishTime}",
      style: TextStyle(
        fontSize: 10.0,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
    );
  }
}