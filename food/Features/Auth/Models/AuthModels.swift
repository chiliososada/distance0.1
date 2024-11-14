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



//// MARK: - Auth State
//enum AuthState {
//    case idle
//    case loading
//    case success
//    case failure(AuthError)
//}
