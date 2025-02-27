import Foundation
import MapKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum APIEndpoint {
    // 现有端点...
    case updateUserStatus(isActive: Bool)
    case postLocation(LocationPost.Draft)
    case fetchPosts(region: MKCoordinateRegion)
    case checkSession
    case loginWithFirebaseToken(idToken: String)
    // 新增认证相关端点
    case login(email: String, password: String)
    case register(email: String, name: String, password: String)
    case updatePassword(currentPassword: String, newPassword: String)
    case deleteAccount(password: String)
    
    var headers: [String: String] {
        var headers = ["Content-Type": "application/json"]
        return headers
    }
    
    var method: HTTPMethod {
        switch self {
        case .updateUserStatus, .postLocation, .login, .register, .updatePassword, .deleteAccount,.loginWithFirebaseToken:
            return .post
        case .fetchPosts, .checkSession:
            return .get
        }
        
    }
    
    var path: String {
        switch self {
        // 现有路径...
        case .updateUserStatus:
            return "/api/users/status"
        case .postLocation:
            return "/api/posts"
        case .fetchPosts:
            return "/api/posts/nearby"
        case .checkSession:
            return "/api/v1/auth/checksession"
        case .loginWithFirebaseToken:
            return "/api/v1/login"
        // 新增路径
        case .login:
            return "/api/v1/login"
        case .register:
            return "/api/v1/auth/register"
        case .updatePassword:
            return "/api/v1/auth/password"
        case .deleteAccount:
            return "/api/v1/auth/account"
        }
    }
    
    var body: Encodable? {
        switch self {
        // 现有请求体...
        case .loginWithFirebaseToken(let idToken):
            return ["id_token": idToken]
                
        case .updateUserStatus(let isActive):
            return ["isActive": isActive]
        case .postLocation(let draft):
            return draft
        case .fetchPosts(let region):
            return [
                "latitude": region.center.latitude,
                "longitude": region.center.longitude,
                "latitudeDelta": region.span.latitudeDelta,
                "longitudeDelta": region.span.longitudeDelta
            ]
        case .checkSession:
            return nil
            
        // 新增请求体
        case .login(let email, let password):
            return ["email": email, "password": password]
        case .register(let email, let name, let password):
            return ["email": email, "name": name, "password": password]
        case .updatePassword(let currentPassword, let newPassword):
            return ["currentPassword": currentPassword, "newPassword": newPassword]
        case .deleteAccount(let password):
            return ["password": password]
        }
    }
}
