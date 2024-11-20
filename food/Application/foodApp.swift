import SwiftUI
import MapKit
import CoreLocation
import FirebaseCore

@main
struct FoodApp: App {
    // 初始化全局管理器，确保 Firebase 配置
    @StateObject private var managers = GlobalManagers.shared
    // 使用 UIApplicationDelegateAdaptor 集成 UIKit 的 AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // 监听应用程序的场景状态（前台、后台等）
    @Environment(\.scenePhase) private var scenePhase
    
    // 定义应用程序的场景体
    var body: some Scene {
        WindowGroup {
            ContentView()
                // 通过环境对象向视图层次结构注入各种管理器
                .environmentObject(managers.tabBarManager)
                .environmentObject(managers.authManager)
                .environmentObject(managers.navigationManager)
                .environmentObject(managers.locationManager)
        }
    }
    
  
}

// 仅在调试模式下定义预览提供器
#if DEBUG
struct FoodApp_Previews: PreviewProvider {
    static var previews: some View {
        // 设置预览内容，注入所需的环境对象
        ContentView()
            .environmentObject(GlobalManagers.preview.tabBarManager)
            .environmentObject(GlobalManagers.preview.authManager)
            .environmentObject(GlobalManagers.preview.navigationManager)
            .environmentObject(GlobalManagers.preview.locationManager)
    }
}
#endif
