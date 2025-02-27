import SwiftUI
import UIKit

final class AppRootManager {
    static let shared = AppRootManager()
    private var contentViewController: UIHostingController<AnyView>?
    private init() {}
    
    func setupRootView(
        for windowScene: UIWindowScene,
        managers: EnvironmentManagers
    ) -> UIWindow {
        print("Setting up root view")
        let window = UIWindow(windowScene: windowScene)
        
        // 始终使用ContentView作为根视图
        if contentViewController == nil {
            contentViewController = UIHostingController(
                rootView: AnyView(
                    ContentView()
                        .environmentObject(managers.authManager)
                        .environmentObject(managers.navigationManager)
                        .environmentObject(managers.locationManager)
                )
            )
        }
        
        window.rootViewController = contentViewController
        window.makeKeyAndVisible()
        return window
    }

    
    func resetRootView(
        window: UIWindow,
        to destination: RootViewDestination,
        managers: EnvironmentManagers
    ) {
        // 重置导航状态
        managers.navigationManager.resetNavigation()
        
        // 使用ContentView但不创建新实例，只需触发内部状态更新
        if let authManager = managers.authManager as? AuthManager {
            // 触发AuthManager的状态更新，ContentView会响应这些变化
            Task { @MainActor in
                try? await authManager.validateCurrentSession()
            }
        }
    }
    
    private func makeRootView(
        for destination: RootViewDestination,
        managers: EnvironmentManagers
    ) -> some View {
        Group {
            switch destination {
            case .home:
                HomeView()
                    .environmentObject(managers.authManager)
                    .environmentObject(managers.navigationManager)
                    .environmentObject(managers.locationManager)
            case .verification(let email):
                VerificationView(email: email)
                    .environmentObject(managers.authManager)
                    .environmentObject(managers.navigationManager)
            case .login:
                HomeLoginView()
                    .environmentObject(managers.authManager)
                    .environmentObject(managers.navigationManager)
            }
        }
    }
}

enum RootViewDestination {
    case home
    case verification(email: String)
    case login
}
