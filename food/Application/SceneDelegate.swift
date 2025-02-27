import UIKit
import SwiftUI
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    static var shared: SceneDelegate?
    var window: UIWindow?
    private let managers = GlobalManagers.shared
    private var isCheckingAuth = false
    private var authCheckTask: Task<Void, Never>?
    var scenePhase: ScenePhase = .inactive
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        Self.shared = self
        checkAuth()
    }
    
    // MARK: - Scene Lifecycle
    func sceneDidBecomeActive(_ scene: UIScene) {
        scenePhase = .active
        handleScenePhase(.active)
        checkSession()  // 添加会话检查
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
            break
        case .inactive:
            UserDefaults.standard.synchronize()
        case .background:
            if managers.isLocationManagerInitialized() {
                managers.locationManager.stopUpdatingLocation()
            }
            authCheckTask?.cancel()
        @unknown default:
            break
        }
    }
    
    private func checkSession() {
        Task { @MainActor in
            do {
                let isValid = try await UserService.shared.checkSession()
                if !isValid {
                    // 会话无效，重置导航状态并返回登录界面
                    resetNavigationState()
                } else {
                    // 会话有效，更新用户状态
                    try await updateUserStatus(isActive: true)
                }
            } catch {
                print("Session check error: \(error.localizedDescription)")
                resetNavigationState()
            }
        }
    }
    
    private func updateUserStatus(isActive: Bool) async throws {
        try await UserService.shared.updateUserStatus(isActive: isActive)
    }
    
    private func checkAuth() {
        guard !isCheckingAuth else { return }
        
        authCheckTask?.cancel()
        authCheckTask = Task { @MainActor [weak self] in
            guard let self = self else { return }
            
            self.isCheckingAuth = true
            defer { self.isCheckingAuth = false }
            
            // 等待认证管理器初始化完成
            while !managers.authManager.isInitialized {
                try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
            }
            
            do {
                // 检查会话是否有效
                if try await managers.authManager.validateCurrentSession() {
                    // 如果会话有效，确保在主页
                    if managers.navigationManager.selectedTab != .home {
                        managers.navigationManager.navigateToHome()
                    }
                } else {
                    // 会话无效，重置导航
                    self.resetNavigationState()
                }
            } catch {
                print("Auth check error: \(error.localizedDescription)")
                self.resetNavigationState()
            }
        }
    }
    
    private func updateUIForUser(_ user: User) async {
        if user.isEmailVerified {
            if managers.authManager.userProfile != nil {
                if managers.navigationManager.selectedTab != .home {
                    managers.navigationManager.navigateToHome()
                }
            }
        } else {
            managers.navigationManager.resetNavigation()
            managers.navigationManager.navigate(to: .verification(email: user.email ?? ""))
        }
    }
    
    private func resetNavigationState() {
        managers.navigationManager.resetNavigation()
    }
}
