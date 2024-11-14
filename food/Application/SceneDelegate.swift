import UIKit
import SwiftUI
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    // Create instances of the managers
    private let tabBarManager = TabBarManager()
    private let authManager = AuthManager()
    private let navigationManager = AppNavigationManager.shared
    private let locationManager = LocationManager.shared
    private var isCheckingAuth = false
    private var authCheckTimer: Timer?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        print(111)
        if window == nil {
            setupInitialWindow(with: windowScene)
        }
        
        debounceCheckAuth()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        locationManager.requestLocationPermissionIfNeeded()
        debounceCheckAuth()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        UserDefaults.standard.synchronize()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        locationManager.stopUpdatingLocation()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        debounceCheckAuth()
    }
    
    // MARK: - Private Methods
    private func setupInitialWindow(with windowScene: UIWindowScene) {
        window = UIWindow(windowScene: windowScene)
        let contentView = ContentView()
            .environmentObject(tabBarManager)
            .environmentObject(authManager)
            .environmentObject(navigationManager)
            .environmentObject(locationManager)
        
        window?.rootViewController = UIHostingController(rootView: contentView)
        window?.makeKeyAndVisible()
    }
    
    private func checkAndResetRootViewIfNeeded() {
        guard !isCheckingAuth else { return }
        isCheckingAuth = true
        
        Task { @MainActor in
            defer { isCheckingAuth = false }
            
            do {
                if let user = Auth.auth().currentUser {
                    try await user.reload()
                    print("SceneDelegate reloaded user")
                    
                    if user.isEmailVerified {
                        if authManager.userProfile != nil {
                            print("SceneDelegate userProfile")
                            resetRootView(to: .home)
                        }
                    } else {
                        navigationManager.resetNavigation()
                        tabBarManager.resetNavigationState()
                        navigationManager.navigate(to: .verification(email: user.email ?? ""))
                    }
                } else {
                    navigationManager.resetNavigation()
                    tabBarManager.resetNavigationState()
                }
            } catch {
                print("SceneDelegate auth check error: \(error.localizedDescription)")
                navigationManager.resetNavigation()
                tabBarManager.resetNavigationState()
            }
        }
    }
    
    @MainActor
    private func resetRootView(to destination: RootViewDestination) {
        print("SceneDelegate resetRootView")
        navigationManager.resetNavigation()
        tabBarManager.resetNavigationState()
        
        guard let window = self.window else { return }
        
        if case .home = destination {
            let rootView = makeRootView(for: destination)
            let rootViewController = UIHostingController(rootView: rootView)
            
            UIView.transition(with: window,
                            duration: 0.3,
                            options: .transitionCrossDissolve,
                            animations: {
                window.rootViewController = rootViewController
            }, completion: nil)
        }
    }
    
    private func makeRootView(for destination: RootViewDestination) -> some View {
        Group {
            switch destination {
            case .home:
                HomeView()
            case .verification(let email):
                VerificationView(email: email)
            case .login:
                HomeLoginView()
            }
        }
        .environmentObject(tabBarManager)
        .environmentObject(authManager)
        .environmentObject(navigationManager)
        .environmentObject(locationManager)
    }
    
    private func debounceCheckAuth() {
        authCheckTimer?.invalidate()
        authCheckTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.checkAndResetRootViewIfNeeded()
        }
    }
    
    private enum RootViewDestination {
        case home
        case verification(email: String)
        case login
    }
}
