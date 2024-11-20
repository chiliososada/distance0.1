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
    
    // 如果需要观察这些管理器的变化，将它们标记为 @Published
    @Published var tabBarManager: TabBarManager
    @Published var authManager: AuthManager
    @Published var navigationManager: AppNavigationManager
    @Published var locationManager: LocationManager
    
    private init() {
        print("GlobalManagers initialized")
        
        // Firebase 初始化
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            print("Firebase configured in GlobalManagers")
        }
        
        // 初始化各个管理器
        self.tabBarManager = TabBarManager()
        self.navigationManager = AppNavigationManager.shared
        self.locationManager = LocationManager.shared
        self.authManager = AuthManager()
    }
    
    var environmentManagers: EnvironmentManagers {
        EnvironmentManagers(
            tabBarManager: tabBarManager,
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

