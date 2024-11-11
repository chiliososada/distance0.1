//
//  LocationManager.swift
//  food
//
//  Created by toyousoft on 2024/11/10.
//

import Foundation
import CoreLocation
import MapKit
import Combine

// MARK: - Location Manager
final class LocationManager: NSObject, ObservableObject {
    // MARK: - Singleton
    static let shared = LocationManager()
    
    // MARK: - Published Properties
    /// 用户当前位置
    @Published var userLocation: CLLocation?
    /// 位置授权状态
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    /// 位置服务是否可用
    @Published private(set) var isLocationServicesEnabled = false
    
    // MARK: - Private Properties
    private let locationManager: CLLocationManager
    private let searchCompleter = MKLocalSearchCompleter()
    private var searchCompleterDelegate: SearchCompleterDelegate?
    
    // MARK: - Callback Properties
    /// 位置更新回调
    var locationUpdated: ((CLLocationCoordinate2D) -> Void)?
    /// 搜索结果更新回调
    var searchResultsUpdated: (([MKLocalSearchCompletion]) -> Void)?
    /// 搜索错误回调
    var searchError: ((Error) -> Void)?
    
    // MARK: - Initialization
    private override init() {
        locationManager = CLLocationManager()
        super.init()
        
        setupLocationManager()
        setupSearchCompleter()
    }
    
    // MARK: - Setup Methods
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // 检查位置服务是否启用
        isLocationServicesEnabled = CLLocationManager.locationServicesEnabled()
    }
    
    private func setupSearchCompleter() {
        searchCompleterDelegate = SearchCompleterDelegate()
        searchCompleterDelegate?.didUpdateResults = { [weak self] results in
            self?.searchResultsUpdated?(results)
        }
        searchCompleterDelegate?.didFailWithError = { [weak self] error in
            self?.searchError?(error)
        }
        searchCompleter.delegate = searchCompleterDelegate
    }
    
    // MARK: - Public Methods
    /// 请求位置权限（如果需要）
    func requestLocationPermissionIfNeeded() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // 用户已经拒绝或无法获取位置权限
            handleLocationPermissionDenied()
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    /// 开始更新位置
    func startUpdatingLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            handleLocationServicesDisabled()
            return
        }
        locationManager.startUpdatingLocation()
    }
    
    /// 停止更新位置
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    /// 执行位置搜索
    /// - Parameter query: 搜索关键词
    func searchLocation(query: String) {
        searchCompleter.queryFragment = query
    }
    
    // MARK: - Private Methods
    private func handleLocationPermissionDenied() {
        // 处理位置权限被拒绝的情况
        print("Location permission denied")
        // TODO: 实现提示用户开启位置权限的逻辑
    }
    
    private func handleLocationServicesDisabled() {
        // 处理位置服务被禁用的情况
        print("Location services are disabled")
        // TODO: 实现提示用户开启位置服务的逻辑
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        case .denied, .restricted:
            handleLocationPermissionDenied()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        userLocation = location
        locationUpdated?(location.coordinate)
        
        // 如果只需要获取一次位置，可以停止更新
        // manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error.localizedDescription)")
        // TODO: 实现错误处理逻辑
    }
}

// MARK: - Search Completer Delegate
private final class SearchCompleterDelegate: NSObject, MKLocalSearchCompleterDelegate {
    var didUpdateResults: (([MKLocalSearchCompletion]) -> Void)?
    var didFailWithError: ((Error) -> Void)?
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        didUpdateResults?(completer.results)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        didFailWithError?(error)
    }
}

// MARK: - Location Search Extension
extension LocationManager {
    /// 执行详细的位置搜索
    /// - Parameters:
    ///   - searchText: 搜索关键词
    ///   - completion: 搜索完成回调，返回位置结果数组
    func performLocationSearch(
        searchText: String,
        completion: @escaping ([MKMapItem]) -> Void
    ) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchText
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response, error == nil else {
                completion([])
                return
            }
            completion(response.mapItems)
        }
    }
    
    /// 反向地理编码：从坐标获取地址
    /// - Parameters:
    ///   - coordinate: 需要解析的坐标
    ///   - completion: 完成回调，返回地址信息
    func reverseGeocode(
        coordinate: CLLocationCoordinate2D,
        completion: @escaping (CLPlacemark?) -> Void
    ) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil else {
                completion(nil)
                return
            }
            completion(placemarks?.first)
        }
    }
}

// MARK: - Helper Methods
extension LocationManager {
    /// 获取两个位置之间的距离
    /// - Parameters:
    ///   - from: 起始位置
    ///   - to: 目标位置
    /// - Returns: 距离（米）
    func getDistance(from: CLLocation, to: CLLocation) -> CLLocationDistance {
        return from.distance(from: to)
    }
    
    /// 检查app是否有位置权限
    /// - Returns: 是否有位置权限
    func hasLocationPermission() -> Bool {
        let status = locationManager.authorizationStatus
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }
}

// MARK: - Preview Helper
#if DEBUG
extension LocationManager {
    /// 创建测试用的位置管理器实例
    static func preview() -> LocationManager {
        let manager = LocationManager.shared
        manager.userLocation = CLLocation(latitude: 37.3346, longitude: -122.0090) // Apple Park
        return manager
    }
}
#endif
