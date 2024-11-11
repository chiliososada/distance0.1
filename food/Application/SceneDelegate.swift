import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    // Create instances of the managers
    private let tabBarManager = TabBarManager()
    private let authManager = AuthManager()
    private let navigationManager = AppNavigationManager.shared
    private let locationManager = LocationManager.shared
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        // Create the ContentView with all required environment objects
        let contentView = ContentView()
            .environmentObject(tabBarManager)
            .environmentObject(authManager)
            .environmentObject(navigationManager)
            .environmentObject(locationManager)
        
        // Set up the window with the properly configured ContentView
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UIHostingController(rootView: contentView)
        window?.makeKeyAndVisible()
    }
    
    // Life cycle methods remain unchanged
    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
}
