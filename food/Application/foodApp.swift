import SwiftUI
import MapKit
import CoreLocation

@main
struct foodApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Initialize all managers as StateObjects
    @StateObject private var tabBarManager = TabBarManager()
    @StateObject private var authManager = AuthManager()
    @StateObject private var navigationManager: AppNavigationManager = .shared
    @StateObject private var locationManager: LocationManager = .shared
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tabBarManager)
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(locationManager)
                .onChange(of: scenePhase) { _, newPhase in
                    handleScenePhase(newPhase)
                }
        }
    }
    
    private func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .active:
            locationManager.requestLocationPermissionIfNeeded()
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
struct foodApp_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TabBarManager())
            .environmentObject(AuthManager())
            .environmentObject(AppNavigationManager.shared)
            .environmentObject(LocationManager.shared)
    }
}
#endif
