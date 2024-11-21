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
            
            do {
                try await Task.sleep(nanoseconds: 200_000_000)
                
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
        if user.isEmailVerified && managers.authManager.userProfile != nil {
            // 通过 NavigationManager 更新导航状态
            managers.navigationManager.resetNavigation()
            if user.isEmailVerified {
                managers.navigationManager.navigate(to: .home)
            } else {
                managers.navigationManager.navigate(to: .verification(email: user.email ?? ""))
            }
        } else if !user.isEmailVerified {
            resetNavigationState()
            managers.navigationManager.navigate(to: .verification(email: user.email ?? ""))
        }
    }
    
    private func resetNavigationState() {
        managers.navigationManager.resetNavigation()
    }
}
