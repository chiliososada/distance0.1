//
//  AuthModels.swift
//  food
//
//  Created by toyousoft on 2024/11/04.
//
import Foundation

// MARK: - Auth Models
struct AuthInputData {
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var verificationCode: String = ""
    var isPasswordVisible: Bool = false
    
    var isEmailValid: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    var isPasswordValid: Bool {
        password.count >= 8
    }
    
    var isConfirmPasswordValid: Bool {
        !confirmPassword.isEmpty && confirmPassword == password
    }
    
    var isVerificationCodeValid: Bool {
        verificationCode.count == 6
    }
}

// MARK: - Auth Errors
enum AuthError: Error {
    case invalidEmail
    case invalidPassword
    case passwordMismatch
    case invalidVerificationCode
    case networkError
    case serverError(String)
    case unknown
    
    var message: String {
        switch self {
        case .invalidEmail:
            return "请输入有效的电子邮箱地址"
        case .invalidPassword:
            return "密码长度必须至少为8位"
        case .passwordMismatch:
            return "两次输入的密码不一致"
        case .invalidVerificationCode:
            return "验证码无效"
        case .networkError:
            return "网络连接失败"
        case .serverError(let message):
            return message
        case .unknown:
            return "未知错误"
        }
    }
}

// MARK: - Auth State
enum AuthState {
    case idle
    case loading
    case success
    case failure(AuthError)
}
