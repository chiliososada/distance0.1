import Foundation
import CoreLocation
import MapKit
class LocationService: NSObject {
    static let shared = LocationService()
    var currentLocation: CLLocation? // 当前用户位置
   
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        return manager
    }()
    var  locationUpdated: ((CLLocationCoordinate2D)->Void)?
    override private init() {
        super.init()
        self.requestPermissionToAccessLocation()
    }

    func requestPermissionToAccessLocation() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
}
extension LocationService: CLLocationManagerDelegate {

    // 当用户更改授权状态时调用
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            manager.startUpdatingLocation()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            print("error with location auth change")
            break
        }
    }

    
    // 当位置更新时调用
       func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           if let location = locations.last {
               self.currentLocation = location // 保存当前用户位置
               locationManager.stopUpdatingLocation()
               locationUpdated?(location.coordinate) // 回调函数提供坐标
           }
       }
    // 当获取位置失败时调用
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription) // 打印错误描述
    }
}

class SearchCompleterDelegate: NSObject, MKLocalSearchCompleterDelegate {
    var didUpdateResults: (([MKLocalSearchCompletion]) -> Void)?
    var didFailWithError: ((Error) -> Void)?
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        didUpdateResults?(completer.results)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        didFailWithError?(error)
    }
}
