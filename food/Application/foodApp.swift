import SwiftUI
import MapKit
import CoreLocation
import FirebaseCore

@main
struct FoodApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var tabBarManager = TabBarManager()
    @StateObject private var authManager: AuthManager
    @StateObject private var navigationManager = AppNavigationManager.shared
    @StateObject private var locationManager = LocationManager.shared
    
    @Environment(\.scenePhase) private var scenePhase
    
    init() {

        _authManager = StateObject(wrappedValue: AuthManager())
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tabBarManager)
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(locationManager)
                .onChange(of: scenePhase) { phase in
                    handleScenePhase(phase)
                }
        }
    }
    
    private func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .active:
            locationManager.requestLocationPermissionIfNeeded()
//            // 检查用户登录状态，但不阻塞UI
//            if authManager.currentUser != nil {
//                Task {
//                    do {
//                        if try await authManager.validateCurrentSession() {
//                            print("Session validated successfully")
//                        } else {
//                            print("Session validation failed")
//                        }
//                    } catch {
//                        print("Session validation error: \(error.localizedDescription)")
//                    }
//                }
//            }
            
        case .inactive:
            UserDefaults.standard.synchronize()
            
        case .background:
            locationManager.stopUpdatingLocation()
            
        @unknown default:
            break
        }
    }
}

#if DEBUG
struct FoodApp_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TabBarManager())
            .environmentObject(AuthManager())
            .environmentObject(AppNavigationManager.shared)
            .environmentObject(LocationManager.shared)
    }
}
#endif
