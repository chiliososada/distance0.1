import UIKit
import SwiftUI
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    static var shared: SceneDelegate?
    var window: UIWindow?
    private let managers = GlobalManagers.shared
    private var isCheckingAuth = false
    private var sessionCheckTask: Task<Void, Never>?
    var scenePhase: ScenePhase = .inactive
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        Self.shared = self
        guard let windowScene = scene as? UIWindowScene else { return }
        
        // 委托给AppRootManager设置根视图
        window = AppRootManager.shared.setupRootView(for: windowScene, managers: managers.environmentManagers)
    }
    
    // MARK: - Scene Lifecycle
    func sceneDidBecomeActive(_ scene: UIScene) {
        scenePhase = .active
        handleScenePhase(.active)
        checkSession()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        scenePhase = .inactive
        handleScenePhase(.inactive)
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        scenePhase = .background
        handleScenePhase(.background)
    }
    
    // MARK: - Private Methods
    private func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .active:
            // 应用激活时的处理
            break
        case .inactive:
            // 保存用户默认值
            UserDefaults.standard.synchronize()
        case .background:
            // 停止位置更新
            if managers.isLocationManagerInitialized() {
                managers.locationManager.stopUpdatingLocation()
            }
            // 取消会话检查任务
            sessionCheckTask?.cancel()
        @unknown default:
            break
        }
    }
    
    private func checkSession() {
        // 取消之前的任务
        sessionCheckTask?.cancel()
        
        // 创建新的会话检查任务
        sessionCheckTask = Task { @MainActor [weak self] in
            guard let self = self else { return }
            guard !isCheckingAuth else { return }
            
            self.isCheckingAuth = true
            defer { self.isCheckingAuth = false }
            
            // 等待认证管理器初始化完成
            while !managers.authManager.isInitialized {
                try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
                if Task.isCancelled { return }
            }
            
            do {
                // 验证会话
                let isValid = try await managers.authManager.validateCurrentSession()
                
                if !isValid {
                    // 会话无效，通知AppRootManager重置到登录状态
                    AppRootManager.shared.resetRootView(
                        window: self.window!,
                        to: .login,
                        managers: self.managers.environmentManagers
                    )
                }
            } catch {
                print("Session check error: \(error.localizedDescription)")
                // 错误时也重置到登录状态
                AppRootManager.shared.resetRootView(
                    window: self.window!,
                    to: .login,
                    managers: self.managers.environmentManagers
                )
            }
        }
    }
}
