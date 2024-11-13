//
//  LoginPasswordViewModel.swift
//  food
//
//  Created by toyousoft on 2024/11/04.
//

import SwiftUI
import FirebaseAuth
import Combine

final class LoginPasswordViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var authData = AuthInputData()
    @Published var isLoginEnabled = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var loginSuccess = false
    
    // MARK: - Properties
    private let authManager: AuthManager
    let emailOrUsername: String
    
    // MARK: - Initialization
    init(emailOrUsername: String, authManager: AuthManager = AuthManager()) {
        self.emailOrUsername = emailOrUsername
        self.authManager = authManager
        self.authData.email = emailOrUsername
    }
    
    // MARK: - Public Methods
    
    /// 验证密码并更新登录按钮状态
    func validatePassword() {
        isLoginEnabled = !authData.password.isEmpty
    }
    
    /// 执行登录操作
    /// - Returns: 登录是否成功
    @MainActor
    func login() async -> Bool {
        print("login")
        // 验证密码不为空
        guard !authData.password.isEmpty else {
            errorMessage = "请输入密码"
            showError = true
            return false
        }
        
        // 设置加载状态
        isLoading = true
        
        do {
            // 尝试登录
            try await authManager.signIn(
                email: emailOrUsername,
                password: authData.password
            )
            
            // 登录成功
            isLoading = false
            loginSuccess = true
            
            // 检查邮箱验证状态
            await authManager.checkEmailVerification()
            
            return true
            
        } catch let error as AuthError {
            // 处理认证错误
            handleAuthError(error)
            return false
            
        } catch {
            // 处理其他错误
            handleUnexpectedError(error)
            return false
        }
    }
    
    // MARK: - Private Methods
    
    /// 处理认证错误
    /// - Parameter error: AuthError 类型的错误
    private func handleAuthError(_ error: AuthError) {
        isLoading = false
        errorMessage = error.errorDescription ?? "登录失败"
        showError = true
    }
    
    /// 处理未预期的错误
    /// - Parameter error: 任意错误类型
    private func handleUnexpectedError(_ error: Error) {
        isLoading = false
        errorMessage = "登录失败：\(error.localizedDescription)"
        showError = true
    }
    
    /// 检查密码强度
    /// - Parameter password: 待检查的密码
    /// - Returns: 密码是否足够强
    private func isPasswordValid(_ password: String) -> Bool {
        return password.count >= AppConstants.Validation.minPasswordLength
    }
}

// MARK: - Preview Helper
extension LoginPasswordViewModel {
    static var preview: LoginPasswordViewModel {
        LoginPasswordViewModel(emailOrUsername: "test@example.com")
    }
}

// MARK: - Error Messages
private extension LoginPasswordViewModel {
    enum ErrorMessages {
        static let emptyPassword = "请输入密码"
        static let invalidPassword = "密码格式不正确"
        static let networkError = "网络连接失败，请检查网络后重试"
        static let unknownError = "登录失败，请稍后重试"
    }
}

// MARK: - Validation
private extension LoginPasswordViewModel {
    /// 验证输入的有效性
    /// - Returns: 是否验证通过
    func validateInput() -> Bool {
        guard !authData.password.isEmpty else {
            errorMessage = ErrorMessages.emptyPassword
            showError = true
            return false
        }
        
        guard isPasswordValid(authData.password) else {
            errorMessage = ErrorMessages.invalidPassword
            showError = true
            return false
        }
        
        return true
    }
}
