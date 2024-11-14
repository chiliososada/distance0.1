//
//  SessionManager.swift
//  food
//
//  Created by toyousoft on 2024/11/13.
//
import  SwiftUI

final class SessionManager {
    static let shared = SessionManager()
    
    private let userDefaults: UserDefaults
    private let keychain: KeychainWrapper
    
    private enum KeychainKey {
            static let authToken = "authToken"
            static let refreshToken = "refreshToken"
        }
    
    init(userDefaults: UserDefaults = .standard, keychain: KeychainWrapper = .standard) {
        self.userDefaults = userDefaults
        self.keychain = keychain
    }
    
    func updateSession(user: UserProfile?) async {
        if let user = user {
            // 保存用户配置文件到 UserDefaults
            if let encoded = try? JSONEncoder().encode(user) {
                userDefaults.set(encoded, forKey: AppConstants.UserDefaultsKeys.userProfile)
            }
            userDefaults.set(true, forKey: AppConstants.UserDefaultsKeys.isLoggedIn)
        }
        userDefaults.synchronize()
    }
    
    func clearSession() async {
        // 清除所有会话数据
        userDefaults.removeObject(forKey: AppConstants.UserDefaultsKeys.userProfile)
        userDefaults.removeObject(forKey: AppConstants.UserDefaultsKeys.isLoggedIn)
        userDefaults.removeObject(forKey: AppConstants.UserDefaultsKeys.authToken)
        userDefaults.removeObject(forKey: AppConstants.UserDefaultsKeys.pushToken)
        userDefaults.synchronize()
        
        // 清除 Keychain 数据
        keychain.removeAllKeys()
    }
    /// 保存认证令牌
        func saveAuthToken(_ token: String) {
            try? keychain.set(token, forKey: KeychainKey.authToken)
        }
        
        /// 获取认证令牌
        func getAuthToken() -> String? {
            try? keychain.string(forKey: KeychainKey.authToken)
        }
        
        /// 保存刷新令牌
        func saveRefreshToken(_ token: String) {
            try? keychain.set(token, forKey: KeychainKey.refreshToken)
        }
        
        /// 获取刷新令牌
        func getRefreshToken() -> String? {
            try? keychain.string(forKey: KeychainKey.refreshToken)
        }
        
        /// 清除所有令牌
        func clearTokens() {
            keychain.removeAllKeys()
        }
}
