import SwiftUI
import MapKit
import CoreLocation
import FirebaseCore

@main
struct FoodApp: App {
    @StateObject private var coordinator = AppCoordinator.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            coordinator.rootView()
        }
    }
}

final class AppCoordinator: ObservableObject {
    static let shared = AppCoordinator()
    
    private var contentView: ContentView?
    private let managers: GlobalManagers
    
    private init() {
        self.managers = GlobalManagers.shared
    }
    
    func rootView() -> some View {
        if contentView == nil {
            contentView = ContentView()
        }
        
        return contentView!
            .environmentObject(managers.authManager)
            .environmentObject(managers.navigationManager)
    }
}
