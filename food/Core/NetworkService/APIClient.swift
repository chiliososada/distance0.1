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
        let endpoint = APIEndpoint.loginWithFirebaseToken(idToken: idToken)
        let authResponse: AuthResponse = try await fetch(endpoint)
        
        // 使用后台返回的 AuthResponse 直接创建 UserProfile
        let userProfile = UserProfile(backendProfile: BackendUserProfile(
            csrfToken: authResponse.csrfToken,
            uid: authResponse.uid,
            displayName: authResponse.displayName,
            photoUrl: authResponse.photoUrl,
            email: authResponse.email,
            gender: authResponse.gender,
            bio: authResponse.bio
        ))
        
        // 使用 csrfToken 更新会话
        await SessionManager.shared.updateSessionWithToken(idToken: authResponse.csrfToken, profile: userProfile)
        
        return userProfile
    }
}



private struct AuthResponse: Codable {
    let csrfToken: String
    let uid: String
    let displayName: String
    let photoUrl: String?
    let email: String
    let gender: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case csrfToken = "csrf_token"
        case uid
        case displayName = "display_name"
        case photoUrl = "photo_url"
        case email
        case gender
        case bio
    }
}

private struct EmptyResponse: Codable {}
