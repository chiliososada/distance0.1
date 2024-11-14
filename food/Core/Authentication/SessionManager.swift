import SwiftUI
import FirebaseAuth

final class SessionManager {
    static let shared = SessionManager()
    
    private let userDefaults: UserDefaults
    private let keychain: KeychainWrapper
    
    init(userDefaults: UserDefaults = .standard, keychain: KeychainWrapper = .standard) {
        self.userDefaults = userDefaults
        self.keychain = keychain
    }
    
    /// 更新会话信息，主要保存用户配置文件
    func updateSession(user: UserProfile?) async {
        if let user = user {
            // 保存用户配置文件到 UserDefaults
            if let encoded = try? JSONEncoder().encode(user) {
                userDefaults.set(encoded, forKey: AppConstants.UserDefaultsKeys.userProfile)
            }
            // 记录最后登录时间
            userDefaults.set(Date(), forKey: AppConstants.UserDefaultsKeys.lastLoginDate)
        }
        userDefaults.synchronize()
    }
    
    /// 获取保存的用户配置文件
    func getSavedProfile() -> UserProfile? {
        guard let data = userDefaults.data(forKey: AppConstants.UserDefaultsKeys.userProfile) else {
            return nil
        }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }
    
    /// 清除会话数据
    func clearSession() async {
        // 清除本地存储的用户数据
        userDefaults.removeObject(forKey: AppConstants.UserDefaultsKeys.userProfile)
        userDefaults.removeObject(forKey: AppConstants.UserDefaultsKeys.lastLoginDate)
        userDefaults.removeObject(forKey: AppConstants.UserDefaultsKeys.pushToken)
        userDefaults.synchronize()
        
        // 清除其他敏感数据
        keychain.removeAllKeys()
    }
    
    /// 保存推送通知令牌
    func savePushToken(_ token: String) {
        userDefaults.set(token, forKey: AppConstants.UserDefaultsKeys.pushToken)
        userDefaults.synchronize()
    }
    
    /// 获取推送通知令牌
    func getPushToken() -> String? {
        return userDefaults.string(forKey: AppConstants.UserDefaultsKeys.pushToken)
    }
    
    /// 判断用户配置是否需要更新
    func shouldRefreshProfile() -> Bool {
        guard let lastLogin = userDefaults.object(forKey: AppConstants.UserDefaultsKeys.lastLoginDate) as? Date else {
            return true
        }
        // 如果最后登录时间超过24小时，建议刷新配置
        return Date().timeIntervalSince(lastLogin) > 24 * 60 * 60
    }
}
