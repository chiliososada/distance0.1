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
        
        // 场景初始化时进行认证检查
        checkAuth()
    }
    
    // MARK: - Scene Lifecycle
    func sceneDidBecomeActive(_ scene: UIScene) {
        scenePhase = .active
        handleScenePhase(.active)
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
                if let user = Auth.auth().currentUser {
                    try await user.reload()
                    await self.updateUIForUser(user)
                } else {
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
                // 如果用户已验证且有profile，只需确保在主页
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
