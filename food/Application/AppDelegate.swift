//
//  AppDelegate.swift
//  food
//
//  Created by toyousoft on 2024/11/10.
//

import SwiftUI
import UserNotifications
import CoreLocation
import FirebaseCore
/// 应用程序委托类，负责处理应用程序级别的事件和设置
/// - 管理应用程序生命周期
/// - 处理远程通知
/// - 配置应用程序设置
class AppDelegate: NSObject, UIApplicationDelegate {
    
    // MARK: - Application Lifecycle
    
    /// 应用程序启动时调用
    /// - Parameters:
    ///   - application: UIApplication实例
    ///   - launchOptions: 启动选项字典
    /// - Returns: 是否成功完成启动
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // 初始化 Firebase，添加在 setupApp() 之前
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
        
        // 更新服务器端的推送令牌
        Task {
            do {
                try await AuthManager().updatePushToken(token)
            } catch {
                print("Failed to update push token: \(error.localizedDescription)")
            }
        }
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
        configureNotifications()
        setupNetworkMonitoring()
        setupLogging()
        registerDefaultsSettings()
    }
    
    /// 配置通知设置
    func configureNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        // 请求通知权限
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
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
    // 添加 Firebase 配置方法
      private func setupFirebase() {
          #if DEBUG
          // 在调试模式下可以启用 Firebase 调试日志
          // FirebaseConfiguration.shared.setLoggerLevel(.debug)
          print("Firebase 已初始化")
          #endif
      }
    /// 注册默认设置
    func registerDefaultsSettings() {
        let defaultSettings: [String: Any] = [
            "isDarkModeEnabled": false,
            "notificationsEnabled": true,
            "locationTrackingEnabled": true
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
        guard let type = userInfo["type"] as? String else { return }
        
        DispatchQueue.main.async {
            switch type {
            case "chat":
                // 处理聊天通知
                if let chatIdString = userInfo["chatId"] as? String,
                   let chatId = UUID(uuidString: chatIdString) {
                    let chatRoom = ChatRoom(
                        id: chatId,
                        name: "Loading...",
                        type: .individual,
                        avatar: "default_avatar"
                    )
                    AppNavigationManager.shared.navigate(to: .chatDetail(chatRoom: chatRoom))
                }
            case "post":
                // 处理帖子通知
                if let postId = userInfo["postId"] as? String {
                    let post = LocationPost(
                        title: "Loading...",
                        content: "",
                        authorName: "",
                        locationName: "",
                        latitude: 0,
                        longitude: 0,
                        imageNames: [],
                        avatarImage: "",
                        tags: [],
                        participantsCount: 0,
                        postedTime: "",
                        remainingDays: "",
                        publishDate: "",
                        joinedCount: "",
                        cachedDistance: 0
                    )
                    AppNavigationManager.shared.navigate(to: .postDetail(post: post))
                }
            case "profile":
                // 处理个人资料通知
                AppNavigationManager.shared.navigate(to: .profileEditor)
            default:
                break
            }
        }
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
            // 处理内容刷新推送
            Task {
                do {
                    try await refreshContent()
                    completionHandler(.newData)
                } catch {
                    completionHandler(.failed)
                }
            }
        case "location_update":
            // 处理位置更新推送
            LocationManager.shared.startUpdatingLocation()
            completionHandler(.newData)
        default:
            completionHandler(.noData)
        }
    }
    
    /// 刷新内容
    /// - Throws: 可能抛出网络错误
    func refreshContent() async throws {
        // 实现内容刷新逻辑
        // 通常包括从服务器获取新数据
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
        // 通常使用NWPathMonitor监控网络连接状态
    }
}
