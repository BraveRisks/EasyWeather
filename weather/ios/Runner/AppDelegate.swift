import UIKit
import Flutter
import GoogleMaps
import CoreLocation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
    
        GeneratedPluginRegistrant.register(with: self)
    
        GMSServices.provideAPIKey("AIzaSyBwdqQkcZyQgTn3T4MPLsl3FyQzIM72yto")
    
        // 取得定位服務是否可用
//        if CLLocationManager.locationServicesEnabled() {
//            requestLocationPermission()
//        }
    
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    /// 請求定位權限
    private func requestLocationPermission() {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // 設定最小的更新距離 單位：米(m)
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func openSetting() {
        let ac = UIAlertController(title: "定位權限被拒，請前往設定開啟「定位」服務",
                                   message: nil,
                                   preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "前往設定",
                                   style: .default,
                                   handler:
        { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }))
        
        ac.addAction(UIAlertAction(title: "關閉", style: .cancel, handler: nil))
        window.rootViewController?.present(ac, animated: true, completion: nil)
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 取得定位授權權限狀況
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .denied:
            openSetting()
        case .notDetermined:
            break
        case .restricted:
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 當位置資訊有更新時
        if let location = locations.last {
            print("didUpdateLocations --> \(location)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            manager.stopUpdatingLocation()
            return
        }
    }
}
