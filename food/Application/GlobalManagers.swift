//
//  GlobalManagers.swift.swift
//  food
//
//  Created by toyousoft on 2024/11/20.
//

import FirebaseCore
import Foundation

final class GlobalManagers: ObservableObject {
    static let shared = GlobalManagers()
    
    // 改为 lazy var 避免过早初始化
      
       private(set) lazy var navigationManager = AppNavigationManager.shared
       private(set) lazy var locationManager = LocationManager.shared
       private(set) lazy var authManager = AuthManager()
    
    private init() {
        print("GlobalManagers initialized")
        
        // Firebase 初始化
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

