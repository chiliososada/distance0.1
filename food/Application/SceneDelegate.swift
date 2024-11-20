import UIKit
import SwiftUI
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
   var window: UIWindow?
   
   private var managers: EnvironmentManagers {
       GlobalManagers.shared.environmentManagers
   }
   
   private var isCheckingAuth = false
   private var authCheckTimer: Timer?
   
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
       
       debounceCheckAuth()
   }
   
   func sceneDidBecomeActive(_ scene: UIScene) {
       handleScenePhase(.active)
       debounceCheckAuth()
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
       @unknown default:
           break
       }
   }
   
   private func checkAndResetRootViewIfNeeded() {
       guard !isCheckingAuth else { return }
       isCheckingAuth = true
       
       Task { @MainActor in
           defer { isCheckingAuth = false }
           
           do {
               if let user = Auth.auth().currentUser {
                   try await Task.sleep(nanoseconds: 500_000_000)
                   try await user.reload()
                   print("SceneDelegate reloaded user")
                   
                   if user.isEmailVerified {
                       if managers.authManager.userProfile != nil {
                           print("SceneDelegate userProfile exists")
                           guard let window = self.window else { return }
                           if window.rootViewController?.children.first is UIHostingController<VerificationView> {
                               AppRootManager.shared.resetRootView(
                                   window: window,
                                   to: .home,
                                   managers: managers
                               )
                           }
                       }
                   } else {
                       managers.navigationManager.resetNavigation()
                       managers.tabBarManager.resetNavigationState()
                       managers.navigationManager.navigate(
                           to: .verification(email: user.email ?? "")
                       )
                   }
               } else {
                   managers.navigationManager.resetNavigation()
                   managers.tabBarManager.resetNavigationState()
               }
           } catch {
               print("SceneDelegate auth check error: \(error.localizedDescription)")
               managers.navigationManager.resetNavigation()
               managers.tabBarManager.resetNavigationState()
           }
       }
   }
   
   private func debounceCheckAuth() {
       authCheckTimer?.invalidate()
       authCheckTimer = Timer.scheduledTimer(
           withTimeInterval: 0.5,
           repeats: false
       ) { [weak self] _ in
           self?.checkAndResetRootViewIfNeeded()
       }
   }
}
