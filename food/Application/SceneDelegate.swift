import UIKit
import SwiftUI
import FirebaseAuth

// 场景代理类，负责管理应用程序窗口和场景的生命周期
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?  // 应用程序窗口
    
    // MARK: - 管理器实例
       private let managers = EnvironmentManagers(
           tabBarManager: TabBarManager(),
           authManager: AuthManager(),
           navigationManager: AppNavigationManager.shared,
           locationManager: LocationManager.shared
       )
       
    
    
    
    
    private var isCheckingAuth = false                   // 认证检查状态标志
    private var authCheckTimer: Timer?                   // 认证检查定时器
    
    // MARK: - 场景生命周期方法
    
    // 场景将要连接时调用
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        print(111)
        // 如果窗口未初始化，则进行初始化
        if window == nil {
            setupInitialWindow(with: windowScene)
        }
        
        // 执行防抖动的认证检查
        debounceCheckAuth()
    }
    
    // 场景变为活跃状态时调用
    func sceneDidBecomeActive(_ scene: UIScene) {
        // 请求位置权限（如果需要）
        locationManager.requestLocationPermissionIfNeeded()
        debounceCheckAuth()
    }
    
    // 场景即将进入非活跃状态时调用
    func sceneWillResignActive(_ scene: UIScene) {
        // 同步 UserDefaults 数据
        UserDefaults.standard.synchronize()
    }
    
    // 场景进入后台时调用
    func sceneDidEnterBackground(_ scene: UIScene) {
        // 停止更新位置
        locationManager.stopUpdatingLocation()
    }
    
    // 场景即将进入前台时调用
    func sceneWillEnterForeground(_ scene: UIScene) {
        // 检查认证状态
        debounceCheckAuth()
    }
    
    // MARK: - 私有方法
    
    // 初始化窗口设置
    private func setupInitialWindow(with windowScene: UIWindowScene) {
        window = UIWindow(windowScene: windowScene)
        // 创建主内容视图并注入环境对象
        let contentView = ContentView()
            .environmentObject(tabBarManager)
            .environmentObject(authManager)
            .environmentObject(navigationManager)
            .environmentObject(locationManager)
        
        // 设置根视图控制器
        window?.rootViewController = UIHostingController(rootView: contentView)
        window?.makeKeyAndVisible()
    }
    
    // 检查并在需要时重置根视图
    private func checkAndResetRootViewIfNeeded() {
        // 防止重复检查
        guard !isCheckingAuth else { return }
        isCheckingAuth = true
        
        Task { @MainActor in
            defer { isCheckingAuth = false }
            
            do {
                // 如果用户已登录，刷新用户状态
                if let user = Auth.auth().currentUser {
                    try await user.reload()
                    print("SceneDelegate reloaded user")
                    
                    if user.isEmailVerified {
                        // 邮箱已验证且用户资料存在时，重置到主页
                        if authManager.userProfile != nil {
                            print("SceneDelegate userProfile")
                            resetRootView(to: .home)
                        }
                    } else {
                        // 邮箱未验证时，重置导航并显示验证页面
                        navigationManager.resetNavigation()
                        tabBarManager.resetNavigationState()
                        navigationManager.navigate(to: .verification(email: user.email ?? ""))
                    }
                } else {
                    // 用户未登录时重置导航状态
                    navigationManager.resetNavigation()
                    tabBarManager.resetNavigationState()
                }
            } catch {
                print("SceneDelegate auth check error: \(error.localizedDescription)")
                // 发生错误时重置导航状态
                navigationManager.resetNavigation()
                tabBarManager.resetNavigationState()
            }
        }
    }
    
    // 重置根视图（在主线程执行）
    @MainActor
    private func resetRootView(to destination: RootViewDestination) {
        print("SceneDelegate resetRootView")
        // 重置导航状态
        navigationManager.resetNavigation()
        tabBarManager.resetNavigationState()
        
        guard let window = self.window else { return }
        
        // 如果目标是主页，创建新的根视图并设置过渡动画
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
    
    // 根据目标创建对应的根视图
    private func makeRootView(for destination: RootViewDestination) -> some View {
        Group {
            switch destination {
            case .home:
                HomeView()                    // 主页视图
            case .verification(let email):
                VerificationView(email: email) // 验证页面
            case .login:
                HomeLoginView()               // 登录页面
            }
        }
        // 注入环境对象
        .environmentObject(tabBarManager)
        .environmentObject(authManager)
        .environmentObject(navigationManager)
        .environmentObject(locationManager)
    }
    
    // 防抖动检查认证状态
    private func debounceCheckAuth() {
        // 取消之前的定时器
        authCheckTimer?.invalidate()
        // 设置新的定时器，延迟0.5秒执行认证检查
        authCheckTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.checkAndResetRootViewIfNeeded()
        }
    }
    
    // 根视图目标枚举
    private enum RootViewDestination {
        case home           // 主页
        case verification(email: String)  // 验证页面
        case login         // 登录页面
    }
}
