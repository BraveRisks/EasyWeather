import 'dart:convert';
import 'package:dio/dio.dart';

/// 在Response後，發送成功或失敗前的事件
typedef OnBefore = Function();

/// 成功事件
typedef OnSuccess = Function(Map<String, dynamic> result);

/// 失敗事件
typedef OnFailed = Function(ApiError error, String errMag);

/// 成功或失敗後的完成事件
typedef OnDone = Function();

/// Api Error Type
enum ApiError {

  /// 網路錯誤
  networkError,

  /// 回應錯誤
  responseError,

  /// 轉換JSON錯誤
  parseJSONFailed,

  /// 連線逾時
  timeOut,

  /// Dio library error
  dioError,

  /// 其他
  other,
}

enum ApiPath {
  weather
}

class ApiManager {

  // Reference: https://zaiste.net/programming/dart/howtos/howto-create-singleton-dart/
  static final ApiManager _instance = ApiManager._internal();

  // 工廠模式
  factory ApiManager() => _instance;

  // 初始化
  ApiManager._internal();

  // 外部調用
  static ApiManager get share => _instance;

  /// 連接時間設定，value = 3s
  final int connectTimeout = 3000;

  /// 接收時間設定，value = 3s
  final int receiveTimeout = 3000;

  /// 管理請求資源
  Map<String, CancelToken> _tasks = Map();

  void request(
      ApiPath path,
      Map<String, dynamic> parameters,
      {
        bool debugPrintRequest = true,
        bool debugPrintResponse = true,
        OnBefore onBefore,
        OnSuccess onSuccess,
        OnFailed onFailed,
        OnDone onDone
      }) async {

    Dio dio = Dio();
    CancelToken cancelToken = CancelToken();
    RequestOptions options = RequestOptions();
    options.headers["content-type"] = "application/json";

    options.connectTimeout = connectTimeout;
    options.receiveTimeout = receiveTimeout;

    final apiPath = _convertApiPath(path);

    // 添加共通參數
    parameters["exclude"] = "daily";
    parameters["units"] = "metric";
    parameters["lang"] = "zh_tw";
    parameters["appid"] = "32be38731000e42f21c4a11e721f168f";

    try {
      Response response = await dio.get(
          apiPath,
          queryParameters: parameters,
          options: options,
          cancelToken: cancelToken
      );

      // OnBefore event
      if (onBefore != null) { onBefore(); }

      _tasks[apiPath] = cancelToken;

      // Request
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      if (debugPrintRequest) {
        print("🚀🚀🚀🚀🚀 Request 🚀🚀🚀🚀🚀");
        print("ApiPath = ${response.request.path}");
        print("Parameter = \n${encoder.convert(response.request.queryParameters)}");
      }

      // Response Code not equals 200
      if (response.statusCode != 200) {
        _handleFailed(ApiError.responseError, response.statusMessage, onFailed: onFailed, onDone: onDone);
        return;
      }

      Map<String, dynamic> result = json.decode(response.toString());
      if (result == null) {
        _handleFailed(ApiError.parseJSONFailed, "轉換`JSON格式`失敗", onFailed: onFailed, onDone: onDone);
        return;
      }

      // Response
      if (debugPrintResponse) {
        print("🔥🔥🔥🔥🔥 Response 🔥🔥🔥🔥🔥");
        print("Headers = \n${encoder.convert(response.headers.map)}");
        print("Datas = \n${encoder.convert(result)}");
      }

      if (onSuccess != null) {
        onSuccess(result);
      }
    } on DioError catch (e) {
      switch (e.type) {
        case DioErrorType.CONNECT_TIMEOUT:
        case DioErrorType.RECEIVE_TIMEOUT:
          _handleFailed(ApiError.timeOut, e.toString(), onFailed: onFailed);
          break;
        default:
          _handleFailed(ApiError.dioError, e.toString(), onFailed: onFailed);
          break;
      }
    } catch (e) {
      _handleFailed(ApiError.other, e.toString(), onFailed: onFailed);
    } finally {
      if (onDone != null) { onDone(); }

      // 移除請求過的資源
      _tasks.remove(apiPath);
    }
  }

  /// 將ApiPath轉為對應Url
  String _convertApiPath(ApiPath path) {
    switch (path) {
      case ApiPath.weather:
        return "https://api.openweathermap.org/data/2.5/onecall";
      default:
        return "";
    }
  }

  /// 統一處理Failed
  void _handleFailed(ApiError error, String errMsg, {OnFailed onFailed, OnDone onDone}) {
    if (onFailed != null) {
      Future.delayed(Duration(milliseconds: 500), () {
        onFailed(error, errMsg);

        if (onDone != null) { onDone(); }
      });
    }
  }

  /// 取消請求
  void cancel(ApiPath path) {
    final apiPath = _convertApiPath(path);
    _tasks[apiPath].cancel("$apiPath did cancel.");
    _tasks.remove(apiPath);
  }
}