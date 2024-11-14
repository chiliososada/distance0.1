import SwiftUI
import UserNotifications
import FirebaseCore

/// 应用程序委托类，负责处理应用程序级别的事件和设置
/// - 管理应用程序生命周期
/// - 处理远程通知
/// - 配置全局服务（Firebase、日志、网络监控等）
class AppDelegate: NSObject, UIApplicationDelegate {
    
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
        // 初始化 Firebase
        FirebaseApp.configure()
        setupApp()
        return true
    }
    
    /// 配置和创建场景会话
    /// - Parameters:
    ///   - application: UIApplication实例
    ///   - connectingSceneSession: 要配置的场景会话
    ///   - options: 连接选项
    /// - Returns: 场景配置
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
    
    // MARK: - Remote Notifications
    
    /// 成功注册远程通知设备令牌后调用
    /// - Parameters:
    ///   - application: UIApplication实例
    ///   - deviceToken: 设备令牌数据
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        
        // 保存推送令牌到UserDefaults
        UserDefaults.standard.set(token, forKey: AppConstants.UserDefaultsKeys.pushToken)
        UserDefaults.standard.synchronize()
    }
    
    /// 注册远程通知失败时调用
    /// - Parameters:
    ///   - application: UIApplication实例
    ///   - error: 错误信息
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    /// 接收远程通知时调用
    /// - Parameters:
    ///   - application: UIApplication实例
    ///   - userInfo: 通知内容
    ///   - completionHandler: 完成回调
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        handleSilentPush(userInfo: userInfo, completionHandler: completionHandler)
    }
}

// MARK: - Setup Methods
private extension AppDelegate {
    /// 设置应用程序的各项配置
    func setupApp() {
        configureNotifications()  // 配置通知
        setupNetworkMonitoring()  // 设置网络监控
        setupLogging()           // 设置日志系统
        registerDefaultsSettings() // 注册默认设置
    }
    
    /// 配置通知设置
    /// - 请求通知权限
    /// - 设置通知代理
    /// - 注册远程通知
    func configureNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    /// 设置网络监控
    func setupNetworkMonitoring() {
        NetworkMonitor.shared.startMonitoring()
    }
    
    /// 配置日志系统
    /// 根据编译模式设置不同的日志级别
    func setupLogging() {
        #if DEBUG
        Logger.shared.setLogLevel(.debug)  // 调试模式：显示所有日志
        #else
        Logger.shared.setLogLevel(.error)  // 发布模式：只显示错误日志
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
    /// 应用程序在前台时收到通知的处理
    /// - Parameters:
    ///   - center: 通知中心
    ///   - notification: 收到的通知
    ///   - completionHandler: 完成回调
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .badge, .sound])
    }
    
    /// 用户点击通知时的处理
    /// - Parameters:
    ///   - center: 通知中心
    ///   - response: 用户的响应
    ///   - completionHandler: 完成回调
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        handleNotificationResponse(response.notification.request.content.userInfo)
        completionHandler()
    }
    
    /// 处理通知响应
    /// - Parameter userInfo: 通知内容
    private func handleNotificationResponse(_ userInfo: [AnyHashable: Any]) {
        // 处理通知响应
    }
}

// MARK: - Push Notification Handling
private extension AppDelegate {
    /// 处理静默推送
    /// - Parameters:
    ///   - userInfo: 推送内容
    ///   - completionHandler: 完成回调
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
                    completionHandler(.failed)
                }
            }
        default:
            completionHandler(.noData)
        }
    }
    
    /// 刷新内容
    /// - Throws: 可能抛出网络错误
    func refreshContent() async throws {
        // 实现内容刷新逻辑
    }
}

// MARK: - Logger
/// 日志管理类
class Logger {
    /// 共享实例
    static let shared = Logger()
    
    /// 日志级别枚举
    enum LogLevel: Int {
        case debug = 0    // 调试信息
        case info = 1     // 一般信息
        case warning = 2  // 警告信息
        case error = 3    // 错误信息
    }
    
    /// 当前日志级别
    private var currentLogLevel: LogLevel = .info
    
    /// 设置日志级别
    /// - Parameter level: 要设置的日志级别
    func setLogLevel(_ level: LogLevel) {
        currentLogLevel = level
    }
    
    /// 记录日志
    /// - Parameters:
    ///   - message: 日志消息
    ///   - level: 日志级别
    ///   - file: 源文件名
    ///   - line: 行号
    func log(_ message: String, level: LogLevel, file: String = #file, line: Int = #line) {
        guard level.rawValue >= currentLogLevel.rawValue else { return }
        let fileName = (file as NSString).lastPathComponent
        print("[\(fileName):\(line)][\(level)] \(message)")
    }
}

// MARK: - Network Monitor
/// 网络监控类
class NetworkMonitor {
    /// 共享实例
    static let shared = NetworkMonitor()
    
    /// 开始网络监控
    func startMonitoring() {
        // 实现网络监控逻辑
    }
}
