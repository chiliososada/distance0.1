//
//  foodApp.swift
//  food
//
//  Created by toyousoft on 2024/11/10.
//

import SwiftUI
import MapKit
import CoreLocation

@main
struct foodApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Initialize all managers as StateObjects
    @StateObject private var tabBarManager = TabBarManager()
    @StateObject private var authManager = AuthManager()
    @StateObject private var navigationManager: AppNavigationManager = .shared
    @StateObject private var locationManager: LocationManager = .shared
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tabBarManager)
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(locationManager)
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    handleScenePhase(newPhase)
                }
                .task {
                    await authManager.checkAuthState()
                }
        }
    }
    
    private func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .active:
            Task {
                await authManager.refreshUserStatus()
                locationManager.requestLocationPermissionIfNeeded()
            }
        case .inactive:
            UserDefaults.standard.synchronize()
        case .background:
            locationManager.stopUpdatingLocation()
        @unknown default:
            break
        }
    }
}

// MARK: - Scene Phase Handlers
private extension foodApp {
    /// 处理应用程序进入活动状态
    func handleActivePhase() {
        Task {
            // 刷新用户状态
            await authManager.refreshUserStatus()
            // 请求位置权限（如果需要）
            locationManager.requestLocationPermissionIfNeeded()
        }
    }
    
    /// 处理应用程序进入非活动状态
    func handleInactivePhase() {
        // 同步用户默认设置
        UserDefaults.standard.synchronize()
    }
    
    /// 处理应用程序进入后台状态
    func handleBackgroundPhase() {
        // 停止位置更新
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - Preview Provider
#if DEBUG
struct foodApp_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TabBarManager())
            .environmentObject(AuthManager())
            .environmentObject(AppNavigationManager.shared)
            .environmentObject(LocationManager.shared)
    }
}
#endif
