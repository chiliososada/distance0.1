import SwiftUI
import MapKit
import CoreLocation
import FirebaseCore

// @main 标记这是应用程序的入口点
@main
struct FoodApp: App {
    // 使用 UIApplicationDelegateAdaptor 集成 UIKit 的 AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // 创建各种管理器的状态对象，使用 @StateObject 确保其生命周期与应用程序一致
    @StateObject private var tabBarManager = TabBarManager()         // 标签栏管理器
    @StateObject private var authManager: AuthManager               // 认证管理器
    @StateObject private var navigationManager = AppNavigationManager.shared    // 导航管理器
    @StateObject private var locationManager = LocationManager.shared          // 位置管理器
    
    // 监听应用程序的场景状态（前台、后台等）
    @Environment(\.scenePhase) private var scenePhase
    
    // 初始化方法
    init() {
        // 初始化认证管理器
        _authManager = StateObject(wrappedValue: AuthManager())
    }
    
    // 定义应用程序的场景体
    var body: some Scene {
        WindowGroup {
            ContentView()
                // 通过环境对象向视图层次结构注入各种管理器
                .environmentObject(tabBarManager)
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .environmentObject(locationManager)
                // 监听场景状态变化
                .onChange(of: scenePhase) { phase in
                    handleScenePhase(phase)
                }
        }
    }
    
    // 处理不同场景状态的方法
    private func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .active:
            // 应用程序激活时请求位置权限
            locationManager.requestLocationPermissionIfNeeded()
        case .inactive:
            // 应用程序进入非活动状态时同步 UserDefaults
            UserDefaults.standard.synchronize()
            
        case .background:
            // 应用程序进入后台时停止更新位置
            locationManager.stopUpdatingLocation()
            
        @unknown default:
            // 处理未知的场景状态
            break
        }
    }
}

// 仅在调试模式下定义预览提供器
#if DEBUG
struct FoodApp_Previews: PreviewProvider {
    static var previews: some View {
        // 设置预览内容，注入所需的环境对象
        ContentView()
            .environmentObject(TabBarManager())
            .environmentObject(AuthManager())
            .environmentObject(AppNavigationManager.shared)
            .environmentObject(LocationManager.shared)
    }
}
#endif
