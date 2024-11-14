import SwiftUI
import FirebaseAuth
import Combine

@MainActor
final class LoginPasswordViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var authData = AuthInputData()
    @Published var isLoginEnabled = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var loginSuccess = false
    
    // MARK: - Dependencies
    private let authManager: AuthManager
    
    // MARK: - Initialization
    init(emailOrUsername: String, authManager: AuthManager = AuthManager()) {
        self.authManager = authManager
        self.authData.email = emailOrUsername  // 只需要设置一次email
    }
    
    // MARK: - Public Methods
    
    /// 验证密码并更新登录按钮状态
    func validatePassword() {
        isLoginEnabled = !authData.password.isEmpty
    }
    
    /// 执行登录操作
        func login() async {
            guard validateInput() else { return }
            
            isLoading = true
            defer { isLoading = false }
            print("Starting login process for email: \(authData.email)")
            
            do {
                let credentials = AuthCredentials(
                    email: authData.email,
                    password: authData.password
                )
                
                print("Attempting to sign in...")
                try await authManager.signIn(with: credentials)
                
                // 给Firebase一点时间更新状态
                try? await Task.sleep(nanoseconds: 500_000_000)  // 0.5秒
                
                // 验证登录结果
                if let user = authManager.currentUser {
                    if user.isEmailVerified {
                        print("Login successful, user is verified")
                        await MainActor.run {
                            loginSuccess = true
                        }
                    } else {
                        print("Email not verified")
                        errorMessage = "请先验证您的邮箱"
                        showError = true
                    }
                } else {
                    print("No user found after sign in")
                    errorMessage = "登录失败，请稍后重试"
                    showError = true
                }
                
            } catch let error as AuthError {
                print("Auth error caught: \(error.localizedDescription)")
                handleAuthError(error)
            } catch {
                print("Unexpected error: \(error.localizedDescription)")
                errorMessage = "登录失败：\(error.localizedDescription)"
                showError = true
            }
            
            isLoading = false
        }
    
    // MARK: - Private Methods
    
    /// 验证输入的有效性
    private func validateInput() -> Bool {
        guard !authData.password.isEmpty else {
            errorMessage = "请输入密码"
            showError = true
            return false
        }
        
        guard isPasswordValid(authData.password) else {
            errorMessage = "密码格式不正确"
            showError = true
            return false
        }
        
        return true
    }
    
    /// 处理认证错误
    private func handleAuthError(_ error: AuthError) {
        switch error {
        case .invalidPassword:
            errorMessage = "密码错误"
        case .invalidCredentials:
            errorMessage = "账号或密码错误"
        case .userNotFound:
            errorMessage = "用户不存在"
        case .networkError:
            errorMessage = "网络连接失败，请检查网络后重试"
        case .tooManyRequests:
            errorMessage = "登录尝试次数过多，请稍后重试"
        default:
            errorMessage = error.errorDescription ?? "登录失败"
        }
        showError = true
    }
    
    /// 检查密码强度
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
