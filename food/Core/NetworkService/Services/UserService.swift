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
}
