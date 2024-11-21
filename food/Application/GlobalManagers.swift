import FirebaseCore
import Foundation

final class GlobalManagers: ObservableObject {
    static let shared = GlobalManagers()
    
    // 基础管理器
    private(set) lazy var navigationManager = AppNavigationManager.shared
    private(set) lazy var authManager = AuthManager()
    
    // LocationManager 改为按需获取
    // 改为 internal 访问级别
    internal var _locationManager: LocationManager?
    var locationManager: LocationManager {
        if _locationManager == nil {
            _locationManager = LocationManager.shared
            print("LocationManager initialized on first access")
        }
        return _locationManager!
    }
    
    // 添加检查方法
    func isLocationManagerInitialized() -> Bool {
        return _locationManager != nil
    }
    
    private init() {
        print("GlobalManagers initialized")
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            print("Firebase configured in GlobalManagers")
        }
    }
    
    var environmentManagers: EnvironmentManagers {
        EnvironmentManagers(
            authManager: authManager,
            navigationManager: navigationManager,
            locationManager: locationManager
        )
    }
    
    #if DEBUG
    static var preview: GlobalManagers {
        let instance = GlobalManagers()
        return instance
    }
    #endif
}
