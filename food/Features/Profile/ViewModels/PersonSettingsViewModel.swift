//
//  PersonSettingsViewModel.swift
//  food
//
//  Created by toyousoft on 2024/11/12.
//

import SwiftUI

// MARK: - 设置状态管理
final class PersonSettingsViewModel: ObservableObject {
    @Published var cacheSize: String = "1.7M"
    let appVersion: String = "1.2.8(171)"
    
    private let authManager: AuthManager
    private let navigationManager: AppNavigationManager
    private let tabBarManager: TabBarManager
    
    init(authManager: AuthManager,
         navigationManager: AppNavigationManager = .shared,
         tabBarManager: TabBarManager) {
        self.authManager = authManager
        self.navigationManager = navigationManager
        self.tabBarManager = tabBarManager
    }
    
    func clearCache() {
        cacheSize = "0M"
    }
    
    func checkUpdate() {
    }
    
    @MainActor
      func logout() {
          do {
              try authManager.signOut()
              resetUI()
          } catch {
              print("Logout error: \(error.localizedDescription)")
          }
      }

      private func resetUI() {
          // 重置所有状态
          navigationManager.resetNavigation()
          tabBarManager.resetNavigationState()
          
          // 重置窗口根视图
          if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
             let window = windowScene.windows.first {
              let contentView = ContentView()
                  .environmentObject(authManager)
                  .environmentObject(tabBarManager)
                  .environmentObject(navigationManager)
                  .environmentObject(LocationManager.shared)
              
              window.rootViewController = UIHostingController(rootView: contentView)
              window.makeKeyAndVisible()
          }
      }
}
