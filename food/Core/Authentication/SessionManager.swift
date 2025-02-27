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
    
    /// 使用idToken和用户配置文件更新会话
    func updateSessionWithToken(idToken: String, profile: UserProfile) async {
        // 保存token到keychain
        try? keychain.set(idToken, forKey: AppConstants.UserDefaultsKeys.authToken)
        
        // 保存用户配置文件到UserDefaults
        if let encoded = try? JSONEncoder().encode(profile) {
            userDefaults.set(encoded, forKey: AppConstants.UserDefaultsKeys.userProfile)
        }
        
        // 记录最后登录时间
        userDefaults.set(Date(), forKey: AppConstants.UserDefaultsKeys.lastLoginDate)
        userDefaults.synchronize()
    }
    
    /// 更新会话信息，主要保存用户配置文件（旧方法，保持兼容）
    func updateSession(user: UserProfile?) async {
        if let user = user {
            // 保存用户配置文件到UserDefaults
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
        
        // 清除认证token
        try? keychain.remove(AppConstants.UserDefaultsKeys.authToken)
    }
    
    /// 获取认证token
    func getAuthToken() -> String? {
        return try? keychain.string(forKey: AppConstants.UserDefaultsKeys.authToken)
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
    
    /// 判断会话是否有效 (简化，仅做基本检查)
    func isSessionValid() -> Bool {
        // 只检查token是否存在，实际有效性由API决定
        return getAuthToken() != nil
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
