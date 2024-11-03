import Foundation
import CoreLocation
import Combine
import MapKit

// 统一的 LocationManager 类
class LocationManager: NSObject, ObservableObject {
    // 单例模式
    static let shared = LocationManager()

    // 位置管理器
    private let locationManager: CLLocationManager

    // 公开的用户位置，SwiftUI 自动更新
    @Published var userLocation: CLLocation?

    // 回调函数，用于非 SwiftUI 场景
    var locationUpdated: ((CLLocationCoordinate2D) -> Void)?

    // 搜索建议
    var searchCompleterDelegate = SearchCompleterDelegate()

    override private init() {
        // 初始化位置管理器
        self.locationManager = CLLocationManager()
        super.init()

        // 设置代理和精度
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest

        // 请求权限
        self.requestPermissionToAccessLocation()
    }

    // 请求位置权限
    private func requestPermissionToAccessLocation() {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            print("Location access denied or restricted.")
        }
    }

    // 开始更新位置
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
}

// CLLocationManagerDelegate 扩展
extension LocationManager: CLLocationManagerDelegate {
    
    // 当授权状态更改时
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            print("Location access denied or restricted.")
        }
    }

    // 当位置更新时
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // 更新 SwiftUI 的用户位置
        self.userLocation = location

        // 回调函数提供坐标
        self.locationUpdated?(location.coordinate)

        // 停止进一步更新
        manager.stopUpdatingLocation()
    }

    // 当位置获取失败时
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}


