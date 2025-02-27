import SwiftUI
import UserNotifications
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    
    // MARK: - Properties
    private var managers: EnvironmentManagers?
    
    // MARK: - Application Lifecycle
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // 配置Firebase（如果需要）
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            print("Firebase configured in AppDelegate")
        }
        
        // 初始化全局管理器
        print("AppDelegate: Initializing GlobalManagers")
        managers = GlobalManagers.shared.environmentManagers
        
        // 配置推送通知（如果需要）
        configureNotifications()
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        print("AppDelegate: Configuring scene")
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
}

// MARK: - Notifications
extension AppDelegate: UNUserNotificationCenterDelegate {
    private func configureNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            if let error = error {
                print("AppDelegate: Notification authorization error - \(error.localizedDescription)")
            }
        }
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .badge, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // 处理通知响应
        print("AppDelegate: Handling notification response")
        completionHandler()
    }
}
