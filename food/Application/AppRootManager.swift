//
//  AppRootManager.swift
//  food
//
//  Created by toyousoft on 2024/11/20.
//

import SwiftUI
import UIKit

/// 管理应用程序根视图的单例类
final class AppRootManager {
    static let shared = AppRootManager()
    
    private init() {}
    
    /// 设置应用程序的根视图
    /// - Parameters:
    ///   - windowScene: 窗口场景
    ///   - managers: 需要注入的环境对象
    func setupRootView(
        for windowScene: UIWindowScene,
        managers: EnvironmentManagers
    ) -> UIWindow {
        let window = UIWindow(windowScene: windowScene)
        
        // 创建根内容视图并注入所有必需的环境对象
        let contentView = ContentView()
            .environmentObject(managers.authManager)
            .environmentObject(managers.navigationManager)
            .environmentObject(managers.locationManager)
        
        // 设置根视图控制器
        window.rootViewController = UIHostingController(rootView: contentView)
        window.makeKeyAndVisible()
        
        return window
    }
    
    /// 重置根视图（例如在用户登录/登出时）
    /// - Parameters:
    ///   - window: 当前窗口
    ///   - destination: 目标视图类型
    ///   - managers: 环境管理器
    func resetRootView(
        window: UIWindow,
        to destination: RootViewDestination,
        managers: EnvironmentManagers
    ) {
        // 重置导航状态
        managers.navigationManager.resetNavigation()
        // 创建新的根视图
        let rootView = makeRootView(for: destination, managers: managers)
        let rootViewController = UIHostingController(rootView: rootView)
        
        print("AppRootManager: Resetting root view to \(destination)")
        
        // 使用动画切换根视图
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
                window.rootViewController = rootViewController
            }
        )
    }
    
    /// 根据目标创建相应的根视图
    private func makeRootView(
        for destination: RootViewDestination,
        managers: EnvironmentManagers
    ) -> some View {
        Group {
            switch destination {
            case .home:
                HomeView()
                    .environmentObject(managers.authManager)
                    .environmentObject(managers.navigationManager)
                    .environmentObject(managers.locationManager)
            case .verification(let email):
                VerificationView(email: email)
                    .environmentObject(managers.authManager)
                    .environmentObject(managers.navigationManager)
                    .environmentObject(managers.locationManager)
            case .login:
                HomeLoginView()
                  
                    .environmentObject(managers.authManager)
                    .environmentObject(managers.navigationManager)
                    .environmentObject(managers.locationManager)
            }
        }
    }
}

/// 环境管理器集合
struct EnvironmentManagers {
    let authManager: AuthManager
    let navigationManager: AppNavigationManager
    let locationManager: LocationManager
}

/// 根视图目标枚举
enum RootViewDestination {
    case home
    case verification(email: String)
    case login
}
