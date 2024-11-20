import SwiftUI
import UserNotifications
import FirebaseCore
import FirebaseAuth

/// 应用程序委托类，负责处理应用程序级别的事件和设置
/// - 管理应用程序生命周期
/// - 处理远程通知
/// - 配置全局服务（Firebase、日志、网络监控等）
class AppDelegate: NSObject, UIApplicationDelegate {
    
    // MARK: - Properties
    private var managers: EnvironmentManagers?
    
    // MARK: - Application Lifecycle
    /// 应用程序启动时调用，负责初始化核心服务
    /// - Parameters:
    ///   - application: UIApplication实例
    ///   - launchOptions: 启动选项字典
    /// - Returns: 是否成功完成启动
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        // 2. 然后初始化全局管理器
        print("AppDelegate: Initializing GlobalManagers")
        managers = GlobalManagers.shared.environmentManagers
        
        // 3. 最后配置应用程序其他设置
        print("AppDelegate: Setting up app")
        setupApp()
        
        return true
    }
    
    /// 配置和创建场景会话
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

// MARK: - Setup Methods
private extension AppDelegate {
    /// 设置应用程序的各项配置
    func setupApp() {
        print("AppDelegate: Setting up notifications")
        configureNotifications()      // 配置推送通知系统
        
        print("AppDelegate: Setting up network monitoring")
        setupNetworkMonitoring()      // 初始化网络监控
        
        print("AppDelegate: Setting up logging")
        setupLogging()                // 设置日志记录系统
        
        print("AppDelegate: Registering default settings")
        registerDefaultsSettings()    // 注册应用默认设置
    }
    
    /// 配置通知设置
    func configureNotifications() {
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
    
    /// 设置网络监控
    func setupNetworkMonitoring() {
        NetworkMonitor.shared.startMonitoring()
    }
    
    /// 配置日志系统
    func setupLogging() {
        #if DEBUG
        Logger.shared.setLogLevel(.debug)
        #else
        Logger.shared.setLogLevel(.error)
        #endif
    }
    
    /// 注册应用程序默认设置
    func registerDefaultsSettings() {
        let defaultSettings: [String: Any] = [
            "isDarkModeEnabled": false
        ]
        UserDefaults.standard.register(defaults: defaultSettings)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
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
        handleNotificationResponse(response.notification.request.content.userInfo)
        completionHandler()
    }
    
    private func handleNotificationResponse(_ userInfo: [AnyHashable: Any]) {
        print("AppDelegate: Handling notification response")
    }
}

// MARK: - Push Notification Handling
private extension AppDelegate {
    func handleSilentPush(
        userInfo: [AnyHashable: Any],
        completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        guard let type = userInfo["type"] as? String else {
            completionHandler(.noData)
            return
        }
        
        switch type {
        case "content_refresh":
            Task {
                do {
                    try await refreshContent()
                    completionHandler(.newData)
                } catch {
                    print("AppDelegate: Content refresh failed - \(error.localizedDescription)")
                    completionHandler(.failed)
                }
            }
        default:
            completionHandler(.noData)
        }
    }
    
    func refreshContent() async throws {
        // TODO: 实现具体的内容刷新逻辑
    }
}

// MARK: - Logger
class Logger {
    static let shared = Logger()
    
    enum LogLevel: Int {
        case debug = 0
        case info = 1
        case warning = 2
        case error = 3
    }
    
    private var currentLogLevel: LogLevel = .info
    
    func setLogLevel(_ level: LogLevel) {
        currentLogLevel = level
    }
    
    func log(_ message: String, level: LogLevel, file: String = #file, line: Int = #line) {
        guard level.rawValue >= currentLogLevel.rawValue else { return }
        let fileName = (file as NSString).lastPathComponent
        print("[\(fileName):\(line)][\(level)] \(message)")
    }
}

// MARK: - Network Monitor
class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    func startMonitoring() {
        // TODO: 实现具体的网络监控逻辑
    }
}
