import Foundation
import FirebaseAuth

final class APIClient {
    static let shared = APIClient()
    private let baseURL = "https://192.168.0.9:52340"
    private let sessionManager = SessionManager.shared
    
    private init() {}
    
    func fetch<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        // 从SessionManager获取token而不是Firebase
        if let token = sessionManager.getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = endpoint.body {
            request.httpBody = try? JSONEncoder().encode(body)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    return try JSONDecoder().decode(T.self, from: data)
                } catch {
                    throw APIError.decodingError(error)
                }
            case 401:
                throw APIError.unauthorized
            default:
                throw APIError.serverError(httpResponse.statusCode)
            }
            
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func request(_ endpoint: APIEndpoint) async throws {
        _ = try await fetch(endpoint) as EmptyResponse
    }
    
    // 添加新方法用于Firebase登录流程
    func loginWithFirebaseToken(_ idToken: String) async throws -> UserProfile {
        guard let url = URL(string: baseURL + "/api/v1/auth/login") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["id_token": idToken]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        
        // 解析并返回用户配置文件
        do {
            let userProfile = try JSONDecoder().decode(UserProfile.self, from: data)
            
            // 保存token（假设响应中包含token）
            // 这里需要根据你的后端API响应结构调整
            if let authResponse = try? JSONDecoder().decode(AuthResponse.self, from: data),
               let token = authResponse.token {
                try? KeychainWrapper.standard.set(token, forKey: AppConstants.UserDefaultsKeys.authToken)
            }
            
            return userProfile
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

// 添加认证响应模型
private struct AuthResponse: Codable {
    let token: String?
    let user: UserProfile
}

private struct EmptyResponse: Codable {}
