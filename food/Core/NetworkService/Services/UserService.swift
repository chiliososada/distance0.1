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
    
    // SessionStatus 模型
    struct SessionStatus: Codable {
        let isValid: Bool
        let message: String?
    }
    
    // MARK: - API Methods
    /// 更新用户活跃状态
    func updateUserStatus(isActive: Bool) async throws {
        let endpoint = APIEndpoint.updateUserStatus(isActive: isActive)
        try await apiClient.request(endpoint)
    }
    
    /// 检查会话是否有效
    func checkSession() async throws -> Bool {
        do {
            let endpoint = APIEndpoint.checkSession
            let response: SessionStatus = try await apiClient.fetch(endpoint)
            return response.isValid
        } catch APIError.unauthorized {
            // 认证错误明确视为会话无效
            return false
        } catch {
            // 其他错误需要区分处理，这里保守返回false
            print("Session check error: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 使用Firebase idToken登录
    func loginWithFirebaseToken(_ idToken: String) async throws -> UserProfile {
        return try await apiClient.loginWithFirebaseToken(idToken)
    }
    
    /// 直接使用邮箱密码登录（如果后端支持）
    func login(email: String, password: String) async throws -> UserProfile {
        let endpoint = APIEndpoint.login(email: email, password: password)
        return try await apiClient.fetch(endpoint)
    }
    
    /// 更新密码
    func updatePassword(currentPassword: String, newPassword: String) async throws {
        let endpoint = APIEndpoint.updatePassword(currentPassword: currentPassword, newPassword: newPassword)
        try await apiClient.request(endpoint)
    }
    
    /// 删除账户
    func deleteAccount(password: String) async throws {
        let endpoint = APIEndpoint.deleteAccount(password: password)
        try await apiClient.request(endpoint)
    }
    
    /// 刷新用户配置文件
    func refreshUserProfile() async throws -> UserProfile {
        let endpoint = APIEndpoint.checkSession
        return try await apiClient.fetch(endpoint)
    }
}
