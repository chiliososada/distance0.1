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
        
        // 判断用户是否已登录
        let isAuthenticated = managers.authManager.userProfile != nil
        let destination: RootViewDestination = isAuthenticated ? .home : .login
        
        // 创建适当的根视图
        if contentViewController == nil {
            let rootView = makeRootView(for: destination, managers: managers)
            contentViewController = UIHostingController(rootView: AnyView(rootView))
        }
        
        window.rootViewController = contentViewController
        window.makeKeyAndVisible()
        print("Setting up root view finish")
        return window
    }
    
    func resetRootView(
        window: UIWindow,
        to destination: RootViewDestination,
        managers: EnvironmentManagers
    ) {
        print("Resetting root view to: \(destination)")
        
        // 重置导航状态
        managers.navigationManager.resetNavigation()
        
        // 创建新的根视图
        let rootView = AnyView(makeRootView(for: destination, managers: managers))
        
        if let existingController = contentViewController {
            // 更新现有控制器的根视图
            existingController.rootView = rootView
        } else {
            // 创建新的控制器
            contentViewController = UIHostingController(rootView: rootView)
        }
        
        // 应用转场动画
        if let controller = contentViewController {
            UIView.transition(
                with: window,
                duration: 0.3,
                options: .transitionCrossDissolve,
                animations: {
                    window.rootViewController = controller
                }
            )
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
