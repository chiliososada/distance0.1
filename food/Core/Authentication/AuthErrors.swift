import Foundation
import FirebaseAuth

// MARK: - Auth Errors
enum AuthError: LocalizedError, Equatable {
    case invalidEmail
    case invalidPassword
    case invalidCredentials
    case weakPassword
    case emailAlreadyInUse
    case userNotFound
    case requiresRecentLogin
    case networkError
    case emailNotVerified
    case tooManyRequests
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "邮箱格式无效"
        case .invalidPassword:
            return "密码错误"
        case .invalidCredentials:
            return "账号或密码错误"
        case .weakPassword:
            return "密码强度不够，至少需要6个字符"
        case .emailAlreadyInUse:
            return "该邮箱已被注册"
        case .userNotFound:
            return "用户不存在"
        case .requiresRecentLogin:
            return "此操作需要重新登录"
        case .networkError:
            return "网络连接错误，请检查网络后重试"
        case .emailNotVerified:
            return "邮箱尚未验证"
        case .tooManyRequests:
            return "请求过于频繁，请稍后再试"
        case .unknown(let message):
            return "错误：\(message)"
        }
    }
    
    // MARK: - Firebase Error Mapping
    static func fromFirebaseError(_ error: Error) -> AuthError {
        // 如果已经是 AuthError 类型，直接返回
        if let authError = error as? AuthError {
            return authError
        }
        
        let nsError = error as NSError
        
        switch nsError.code {
        case AuthErrorCode.invalidEmail.rawValue:
            return .invalidEmail
        case AuthErrorCode.wrongPassword.rawValue:
            return .invalidPassword
        case AuthErrorCode.userNotFound.rawValue:
            return .userNotFound
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return .emailAlreadyInUse
        case AuthErrorCode.weakPassword.rawValue:
            return .weakPassword
        case AuthErrorCode.networkError.rawValue:
            return .networkError
        case AuthErrorCode.tooManyRequests.rawValue:
            return .tooManyRequests
        case AuthErrorCode.requiresRecentLogin.rawValue:
            return .requiresRecentLogin
        case AuthErrorCode.invalidCredential.rawValue:
            return .invalidCredentials
        default:
            return .unknown(error.localizedDescription)
        }
    }
}

// MARK: - Equatable Conformance
extension AuthError {
    static func == (lhs: AuthError, rhs: AuthError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidEmail, .invalidEmail),
             (.invalidPassword, .invalidPassword),
             (.invalidCredentials, .invalidCredentials),
             (.weakPassword, .weakPassword),
             (.emailAlreadyInUse, .emailAlreadyInUse),
             (.userNotFound, .userNotFound),
             (.requiresRecentLogin, .requiresRecentLogin),
             (.networkError, .networkError),
             (.emailNotVerified, .emailNotVerified),
             (.tooManyRequests, .tooManyRequests):
            return true
        case (.unknown(let lhsMessage), .unknown(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
