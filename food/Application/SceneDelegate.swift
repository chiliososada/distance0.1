import UIKit
import SwiftUI
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let managers = GlobalManagers.shared.environmentManagers
    private var isCheckingAuth = false
    private var authCheckTask: Task<Void, Never>?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        if window == nil {
            window = AppRootManager.shared.setupRootView(
                for: windowScene,
                managers: managers
            )
        }
        
        checkAuth()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        handleScenePhase(.active)
        checkAuth()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        handleScenePhase(.inactive)
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        handleScenePhase(.background)
    }
    
    private func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .active:
            managers.locationManager.requestLocationPermissionIfNeeded()
        case .inactive:
            UserDefaults.standard.synchronize()
        case .background:
            managers.locationManager.stopUpdatingLocation()
            authCheckTask?.cancel()
        @unknown default:
            break
        }
    }
    
    private func checkAuth() {
        guard !isCheckingAuth else { return }
        
        authCheckTask?.cancel()
        authCheckTask = Task { @MainActor in
            isCheckingAuth = true
            defer { isCheckingAuth = false }
            
            do {
                // 减少延迟时间，或根据场景选择是否需要延迟
                try await Task.sleep(nanoseconds: 200_000_000)
                
                if let user = Auth.auth().currentUser {
                    try await user.reload()
                    await updateUIForUser(user)
                } else {
                    resetNavigationState()
                }
            } catch {
                print("Auth check error: \(error.localizedDescription)")
                resetNavigationState()
            }
        }
    }

    private func updateUIForUser(_ user: User) async {
        if user.isEmailVerified && managers.authManager.userProfile != nil {
            guard let window = window,
                  window.rootViewController?.children.first is UIHostingController<VerificationView> else {
                return
            }
            AppRootManager.shared.resetRootView(window: window, to: .home, managers: managers)
        } else if !user.isEmailVerified {
            resetNavigationState()
            managers.navigationManager.navigate(to: .verification(email: user.email ?? ""))
        }
    }
    
    private func resetNavigationState() {
        managers.navigationManager.resetNavigation()
    }
}
