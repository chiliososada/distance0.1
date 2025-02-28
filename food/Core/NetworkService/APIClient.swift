import Foundation
import FirebaseAuth

final class APIClient {
    static let shared = APIClient()
    
    // 使用常量便于环境切换
    private let baseURL = "https://192.168.0.9:52340"
    private let sessionManager = SessionManager.shared
    
    // 网络请求超时
    private let timeoutInterval: TimeInterval = 30
    // 最大重试次数
    private let maxRetries = 2
    
    private init() {}
    
    func fetch<T: Decodable>(_ endpoint: APIEndpoint, retryCount: Int = 0) async throws -> T {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        request.timeoutInterval = timeoutInterval
        
        // 从SessionManager获取token
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
                    print("httpResponse.statusCode: \(httpResponse.statusCode)")
                    return try JSONDecoder().decode(T.self, from: data)
                } catch {
                    throw APIError.decodingError(error)
                }
            case 401:
                throw APIError.unauthorized
            default:
                throw APIError.serverError(httpResponse.statusCode)
            }
            
        } catch let networkError as URLError where shouldRetry(networkError) && retryCount < maxRetries {
            // 网络错误重试
            try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(retryCount)) * 1_000_000_000))
            return try await fetch(endpoint, retryCount: retryCount + 1)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    private func shouldRetry(_ error: URLError) -> Bool {
        // 判断是否应该重试的错误类型
        switch error.code {
        case .timedOut, .networkConnectionLost, .notConnectedToInternet:
            return true
        default:
            return false
        }
    }
    
    func request(_ endpoint: APIEndpoint) async throws {
        _ = try await fetch(endpoint) as EmptyResponse
    }
    
    // 使用Firebase令牌登录的方法
    func loginWithFirebaseToken(_ idToken: String) async throws -> UserProfile {
        let endpoint = APIEndpoint.loginWithFirebaseToken(idToken: idToken)
        
        let authResponse: AuthResponse = try await fetch(endpoint)

        // 使用后台返回的 AuthResponse 创建 UserProfile
        var userProfile = UserProfile(backendProfile: BackendUserProfile(
            csrfToken: authResponse.csrfToken,
            chatToken: authResponse.chatToken,
            uid: authResponse.uid,
            displayName: authResponse.displayName,
            photoUrl: authResponse.photoUrl,
            email: authResponse.email,
            gender: authResponse.gender,
            bio: authResponse.bio,
            session: authResponse.session,
            chatId: authResponse.chatId,
            chatUrl: authResponse.chatUrl
        ))
        
        // 使用 csrfToken 更新会话
        await SessionManager.shared.updateSessionWithToken(idToken: authResponse.csrfToken, profile: userProfile)
        
        return userProfile
    }
    
}

private struct AuthResponse: Codable {
    let csrfToken: String
    let chatToken: String
    let uid: String
    let displayName: String
    let photoUrl: String?
    let email: String
    let gender: String?
    let bio: String?
    let session: String?
    let chatId: [String]
    let chatUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case csrfToken = "csrf_token"
        case chatToken = "chat_token"
        case uid
        case displayName = "display_name"
        case photoUrl = "photo_url"
        case email
        case gender
        case bio
        case session
        case chatId = "chat_id"
        case chatUrl = "chat_url"
    }
}

private struct EmptyResponse: Codable {}
