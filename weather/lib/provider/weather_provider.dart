import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weather/model/weather.dart';
import 'package:weather/network/api-manager.dart';

class WeatherProvider with ChangeNotifier {

  ApiManager _apiManager;

  Weather weather;
  String district;

  WeatherProvider() {
    _apiManager = ApiManager.share;
  }

  void fetchWeatherBy(LatLng latLng, Geolocator geolocator) async {
    if (weather != null) {
      weather = null;
      district = null;
      notifyListeners();
    }

    // 取得經緯度對應的行政區
    await geolocator.placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
        localeIdentifier: "zh_TW"
    ).then((List<Placemark> places) {
      if (places.isNotEmpty) {
        /*
        Result =
          {
            name: 臺北 101,
            isoCountryCode: TW,
            country: 台灣,
            postalCode: 11049,
            administrativeArea: ,
            subAdministrativeArea: 台北市,
            locality: 信義區,
            subLocality: ,
            thoroughfare: 信義路五段,
            subThoroughfare: 7,
            position: {
              longitude: 121.56508600000001,
              latitude: 25.033678,
              timestamp: 1595993101364,
              mocked: false,
              accuracy: 100.0,
              altitude: 0.0,
              heading: -1.0,
              speed: -1.0,
              speedAccuracy: 0.0
            }
          }
        */

        district = places[0].locality;
      }
    }).catchError((e) {
      print("FromCoordinates error = $e");
    });

    _apiManager.request(
        ApiPath.weather,
        {
          "lat": "${latLng.latitude}",
          "lon" : "${latLng.longitude}"
        },
        debugPrintRequest: true,
        debugPrintResponse: false,
        onSuccess: (result) {
          weather = Weather.fromJSON(result);
          notifyListeners();
        }
    );
  }
}