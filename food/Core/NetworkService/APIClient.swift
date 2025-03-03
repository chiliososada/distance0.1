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
            let encoder = JSONEncoder()
            let data = try encoder.encode(body)
            request.httpBody = data
            
            // 调试打印请求体
            if let bodyString = String(data: data, encoding: .utf8) {
                print("Request body: \(bodyString)")
            }
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // 调试打印响应数据
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response data: \(responseString)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("HTTP Status Code: \(httpResponse.statusCode)")
            
            // 首先检查响应是否包含错误信息
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                if errorResponse.code != 0 {
                    print("服务器返回了错误: \(errorResponse.code) - \(errorResponse.message)")
                    throw APIError.serverError(errorResponse.code)
                }
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    return try decoder.decode(T.self, from: data)
                } catch let decodingError as DecodingError {
                    // 详细打印解码错误
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("解码错误：找不到键 '\(key.stringValue)'，路径：\(context.codingPath.map { $0.stringValue })")
                    case .valueNotFound(let type, let context):
                        print("解码错误：找不到类型为 \(type) 的值，路径：\(context.codingPath.map { $0.stringValue })")
                    case .typeMismatch(let type, let context):
                        print("解码错误：类型不匹配，期望类型 \(type)，路径：\(context.codingPath.map { $0.stringValue })")
                    case .dataCorrupted(let context):
                        print("解码错误：数据已损坏，\(context)")
                    @unknown default:
                        print("未知解码错误: \(decodingError)")
                    }
                    throw APIError.decodingError(decodingError)
                } catch {
                    print("其他错误: \(error)")
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
        
        do {
            let authResponse: AuthResponse = try await fetch(endpoint)
            
            // 使用后台返回的 AuthResponse 直接创建 UserProfile
            let userProfile = UserProfile(backendProfile: BackendUserProfile(
                csrfToken: authResponse.csrfToken,
                uid: authResponse.uid,
                displayName: authResponse.displayName,
                photoUrl: authResponse.photoUrl,
                email: authResponse.email,
                gender: authResponse.gender,
                bio: authResponse.bio,
                chatToken: authResponse.chatToken,
               // session: authResponse.session,
                chatID: authResponse.chatID,
                chatUrl: authResponse.chatUrl
            ))
            
            // 使用 csrfToken 更新会话
            await SessionManager.shared.updateSessionWithToken(idToken: authResponse.csrfToken, profile: userProfile)
            
            return userProfile
        } catch {
            print("登录失败: \(error.localizedDescription)")
            throw error
        }
    }
}

// 添加错误响应结构
private struct ErrorResponse: Codable {
    let code: Int
    let message: String
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
    //let session: String
    let chatID: [String]
    let chatUrl: String
    
    enum CodingKeys: String, CodingKey {
        case csrfToken = "csrf_token"
        case chatToken = "chat_token"
        case uid = "uid"
        case displayName = "display_name"
        case photoUrl = "photo_url"
        case email = "email"
        case gender = "gender"
        case bio = "bio"
        //case session = "Session"
        case chatID = "chat_id"
        case chatUrl = "chat_url"
    }
}

private struct EmptyResponse: Codable {}
