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
    
    // MARK: - API Response Models
    struct ApiResponse<T: Codable>: Codable {
        let code: Int
        let message: String
        let data: T
    }

    struct AuthData: Codable {
        let csrfToken: String
        let chatToken: String
        let uid: String
        let displayName: String
        let photoUrl: String?
        let email: String
        let gender: String?
        let bio: String?
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
            case chatID = "chat_id"
            case chatUrl = "chat_url"
        }
    }
    
    // 添加错误响应结构
    private struct ErrorResponse: Codable {
        let code: Int
        let message: String
    }
    
    private struct EmptyResponse: Codable {}
    
    func fetch<T: Codable>(_ endpoint: APIEndpoint, retryCount: Int = 0) async throws -> T {
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
                print("Raw response: \(responseString)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("HTTP Status Code: \(httpResponse.statusCode)")
            
            // 首先检查是否是API标准响应
            do {
                let apiResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: data)
                if apiResponse.code != 0 {
                    throw APIError.serverError(apiResponse.code)
                }
                return apiResponse.data
            } catch {
                // 不是标准API响应结构，继续下一步尝试
                print("Not standard API response format, trying direct decode: \(error)")
            }
            
            // 检查是否是错误响应
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
                    printDecodingError(decodingError)
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
            // Build the request manually for more control
            guard let url = URL(string: baseURL + endpoint.path) else {
                throw APIError.invalidURL
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = endpoint.method.rawValue
            request.allHTTPHeaderFields = endpoint.headers
            request.timeoutInterval = timeoutInterval
            
            // Handle request body
            if let body = endpoint.body {
                let encoder = JSONEncoder()
                request.httpBody = try encoder.encode(body)
                
                // Debug log
                if let bodyString = String(data: try encoder.encode(body), encoding: .utf8) {
                    print("Request body: \(bodyString)")
                }
            }
            
            // Perform request
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Debug response
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw response: \(responseString)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("HTTP Status Code: \(httpResponse.statusCode)")
            
            // Approach 1: Try using JSONSerialization first for flexible parsing
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("JSON structure keys: \(json.keys.joined(separator: ", "))")
                
                // Check for API response structure with code/message/data
                guard let code = json["code"] as? Int else {
                    throw APIError.invalidResponse
                }
                
                // Check for error
                if code != 0 {
                    let message = json["message"] as? String ?? "Unknown error"
                    throw APIError.serverError(code)
                }
                
                // Extract data object
                guard let dataDict = json["data"] as? [String: Any] else {
                    throw APIError.invalidResponse
                }
                
                // Extract values from data object
                guard let csrfToken = dataDict["csrf_token"] as? String,
                      let uid = dataDict["uid"] as? String,
                      let displayName = dataDict["display_name"] as? String,
                      let email = dataDict["email"] as? String,
                      let chatToken = dataDict["chat_token"] as? String else {
                    throw APIError.invalidResponse
                }
                
                // Extract optional values
                let photoUrl = dataDict["photo_url"] as? String
                let gender = dataDict["gender"] as? String
                let bio = dataDict["bio"] as? String
                let chatID = dataDict["chat_id"] as? [String] ?? []
                let chatUrl = dataDict["chat_url"] as? String ?? ""
                
                // Create backend profile
                let backendProfile = BackendUserProfile(
                    csrfToken: csrfToken,
                    uid: uid,
                    displayName: displayName,
                    photoUrl: photoUrl,
                    email: email,
                    gender: gender,
                    bio: bio,
                    chatToken: chatToken,
                    chatID: chatID,
                    chatUrl: chatUrl
                )
                
                // Create user profile
                let userProfile = UserProfile(backendProfile: backendProfile)
                
                // Save session info
                await sessionManager.updateSessionWithToken(idToken: csrfToken, profile: userProfile)
                
                return userProfile
            }
            
            // Approach 2: Try standard decoding as fallback
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(ApiResponse<AuthData>.self, from: data)
            
            // Check for error
            if apiResponse.code != 0 {
                throw APIError.serverError(apiResponse.code)
            }
            
            // Extract data from response
            let authData = apiResponse.data
            
            // Create backend profile
            let backendProfile = BackendUserProfile(
                csrfToken: authData.csrfToken,
                uid: authData.uid,
                displayName: authData.displayName,
                photoUrl: authData.photoUrl,
                email: authData.email,
                gender: authData.gender,
                bio: authData.bio,
                chatToken: authData.chatToken,
                chatID: authData.chatID,
                chatUrl: authData.chatUrl
            )
            
            let userProfile = UserProfile(backendProfile: backendProfile)
            
            // Save session info
            await sessionManager.updateSessionWithToken(idToken: authData.csrfToken, profile: userProfile)
            
            return userProfile
        } catch let decodingError as DecodingError {
            // Enhanced error logging for decoding issues
            printDecodingError(decodingError)
            throw APIError.decodingError(decodingError)
        } catch {
            print("Login failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    // Helper to print detailed decoding errors
    private func printDecodingError(_ error: DecodingError) {
        switch error {
        case .keyNotFound(let key, let context):
            print("Decoding error: Key not found '\(key.stringValue)', path: \(context.codingPath.map { $0.stringValue })")
        case .valueNotFound(let type, let context):
            print("Decoding error: Value not found for type \(type), path: \(context.codingPath.map { $0.stringValue })")
        case .typeMismatch(let type, let context):
            print("Decoding error: Type mismatch, expected \(type), path: \(context.codingPath.map { $0.stringValue })")
        case .dataCorrupted(let context):
            print("Decoding error: Data corrupted, \(context)")
        @unknown default:
            print("Unknown decoding error: \(error)")
        }
    }
}
