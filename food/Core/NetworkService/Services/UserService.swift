//
//  UserService.swift
//  food
//
//  Created by toyousoft on 2025/02/19.
//

import Foundation

@MainActor
class UserService {
    static let shared = UserService()
    private let apiClient = APIClient.shared
    
    // MARK: - Data Models
    struct UserStatus: Codable {
        let isActive: Bool
        let lastSeen: Date
    }
    
    // 添加 SessionStatus 模型
    struct SessionStatus: Codable {
        let isValid: Bool
        let message: String?  
    }
    
    // MARK: - API Methods
    func updateUserStatus(isActive: Bool) async throws {
        let endpoint = APIEndpoint.updateUserStatus(isActive: isActive)
        try await apiClient.request(endpoint)
    }
    
    func checkSession() async throws -> Bool {
        let endpoint = APIEndpoint.checkSession
        let response: SessionStatus = try await apiClient.fetch(endpoint)
        return response.isValid
    }
    
    
    
    // 使用Firebase idToken登录
       func loginWithFirebaseToken(_ idToken: String) async throws -> UserProfile {
           return try await apiClient.loginWithFirebaseToken(idToken)
       }
       
       // 直接使用邮箱密码登录（可选，如果你的后端支持）
       func login(email: String, password: String) async throws -> UserProfile {
           let endpoint = APIEndpoint.login(email: email, password: password)
           return try await apiClient.fetch(endpoint)
       }
       
       // 更新密码
       func updatePassword(currentPassword: String, newPassword: String) async throws {
           let endpoint = APIEndpoint.updatePassword(currentPassword: currentPassword, newPassword: newPassword)
           try await apiClient.request(endpoint)
       }
       
       // 删除账户
       func deleteAccount(password: String) async throws {
           let endpoint = APIEndpoint.deleteAccount(password: password)
           try await apiClient.request(endpoint)
       }
}
