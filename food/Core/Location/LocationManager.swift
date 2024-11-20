import Foundation
import CoreLocation
import MapKit
import Combine

// MARK: - Location Manager
final class LocationManager: NSObject, ObservableObject {
    // MARK: - Singleton
    static let shared = LocationManager()
    
    // MARK: - Published Properties
    @Published var userLocation: CLLocation?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private(set) var isLocationServicesEnabled = false
    
    // MARK: - Subjects
       let locationSubject = PassthroughSubject<CLLocationCoordinate2D, Never>()
       let addressSubject = PassthroughSubject<String, Never>()
       
       // MARK: - Private Properties
       private let locationManager: CLLocationManager
       private let searchCompleter = MKLocalSearchCompleter()
       private var searchCompleterDelegate: SearchCompleterDelegate?
       private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Callback Properties
    var locationUpdated: ((CLLocationCoordinate2D) -> Void)?
    var searchResultsUpdated: (([MKLocalSearchCompletion]) -> Void)?
    var searchError: ((Error) -> Void)?
    
    // MARK: - Initialization
    private override init() {
            locationManager = CLLocationManager()
            super.init()
            
            setupLocationManager()
            setupSearchCompleter()
            setupAddressUpdates()
        }
    
    // MARK: - Setup Methods
    private func setupLocationManager() {
           locationManager.delegate = self
           locationManager.desiredAccuracy = kCLLocationAccuracyBest
           
           checkLocationServices()
           authorizationStatus = locationManager.authorizationStatus
       }
    private func setupAddressUpdates() {
          // 监听位置更新，自动更新地址
          locationSubject
              .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
              .sink { [weak self] coordinate in
                  self?.updateAddress(for: coordinate)
              }
              .store(in: &cancellables)
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
    private func checkLocationServices() {
           DispatchQueue.global().async { [weak self] in
               let servicesEnabled = CLLocationManager.locationServicesEnabled()
               DispatchQueue.main.async {
                   self?.isLocationServicesEnabled = servicesEnabled
               }
           }
       }
    
    private func updateAddress(for coordinate: CLLocationCoordinate2D) {
          reverseGeocode(coordinate: coordinate) { [weak self] placemark in
              if let address = self?.formatAddress(from: placemark) {
                  self?.addressSubject.send(address)
              }
          }
      }
    private func formatAddress(from placemark: CLPlacemark?) -> String {
          guard let placemark = placemark else { return "Location Unknown" }
          
          return [
              placemark.subLocality,
              placemark.locality,
              placemark.administrativeArea
          ]
          .compactMap { $0 }
          .filter { !$0.isEmpty }
          .joined(separator: ", ")
      }
    // MARK: - Public Methods
    func requestLocationPermissionIfNeeded() {
        let currentStatus = locationManager.authorizationStatus
        
        switch currentStatus {
        case .notDetermined:
            DispatchQueue.global().async {
                self.locationManager.requestWhenInUseAuthorization()
            }
        case .restricted, .denied:
            handleLocationPermissionDenied()
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    // MARK: - Public Methods
    func startUpdatingLocation() {
        // 在后台线程检查位置服务状态
        DispatchQueue.global().async { [weak self] in
            let servicesEnabled = CLLocationManager.locationServicesEnabled()
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.isLocationServicesEnabled = servicesEnabled
                guard servicesEnabled else {
                    self.handleLocationServicesDisabled()
                    return
                }
                
                switch self.locationManager.authorizationStatus {
                case .authorizedWhenInUse, .authorizedAlways:
                    self.locationManager.startUpdatingLocation()
                case .notDetermined:
                    self.requestLocationPermissionIfNeeded()
                case .restricted, .denied:
                    self.handleLocationPermissionDenied()
                @unknown default:
                    break
                }
            }
        }
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func searchLocation(query: String) {
        searchCompleter.queryFragment = query
    }
    
    // MARK: - Private Methods
    private func handleLocationPermissionDenied() {
        DispatchQueue.main.async {
            self.isLocationServicesEnabled = false
            // TODO: 实现提示用户开启位置权限的逻辑
            print("Location permission denied")
        }
    }
    
    private func handleLocationServicesDisabled() {
        DispatchQueue.main.async {
            self.isLocationServicesEnabled = false
            // TODO: 实现提示用户开启位置服务的逻辑
            print("Location services are disabled")
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
  
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.authorizationStatus = manager.authorizationStatus
                
                // 在授权状态变化时检查位置服务状态
                DispatchQueue.global().async {
                    let servicesEnabled = CLLocationManager.locationServicesEnabled()
                    
                    DispatchQueue.main.async {
                        self.isLocationServicesEnabled = servicesEnabled
                        
                        if servicesEnabled {
                            switch manager.authorizationStatus {
                            case .authorizedWhenInUse, .authorizedAlways:
                                self.startUpdatingLocation()
                            case .denied, .restricted:
                                self.handleLocationPermissionDenied()
                            case .notDetermined:
                                break
                            @unknown default:
                                break
                            }
                        } else {
                            self.handleLocationServicesDisabled()
                        }
                    }
                }
            }
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
          guard let location = locations.last else { return }
          
          DispatchQueue.main.async { [weak self] in
              guard let self = self else { return }
              self.userLocation = location
              self.locationSubject.send(location.coordinate)
              self.locationUpdated?(location.coordinate)
          }
      }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            print("Location update failed: \(error.localizedDescription)")
            // TODO: 实现错误处理逻辑
        }
    }
}

// MARK: - Search Completer Delegate
private final class SearchCompleterDelegate: NSObject, MKLocalSearchCompleterDelegate {
    var didUpdateResults: (([MKLocalSearchCompletion]) -> Void)?
    var didFailWithError: ((Error) -> Void)?
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.didUpdateResults?(completer.results)
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.didFailWithError?(error)
        }
    }
}

// MARK: - Location Search Extension
extension LocationManager {
    func performLocationSearch(
        searchText: String,
        completion: @escaping ([MKMapItem]) -> Void
    ) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchText
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            DispatchQueue.main.async {
                guard let response = response, error == nil else {
                    completion([])
                    return
                }
                completion(response.mapItems)
            }
        }
    }
    
    func reverseGeocode(
        coordinate: CLLocationCoordinate2D,
        completion: @escaping (CLPlacemark?) -> Void
    ) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    completion(nil)
                    return
                }
                completion(placemarks?.first)
            }
        }
    }
}

// MARK: - Helper Methods
extension LocationManager {
    func getDistance(from: CLLocation, to: CLLocation) -> CLLocationDistance {
        return from.distance(from: to)
    }
    
    func hasLocationPermission() -> Bool {
        let status = locationManager.authorizationStatus
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }
}

// MARK: - Preview Helper
#if DEBUG
extension LocationManager {
    static func preview() -> LocationManager {
        let manager = LocationManager.shared
        manager.userLocation = CLLocation(latitude: 37.3346, longitude: -122.0090)
        return manager
    }
}
#endif
