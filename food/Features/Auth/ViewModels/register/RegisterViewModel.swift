import Foundation
import SwiftUI

final class RegisterViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var emailOrPhone = ""
    @Published var isValid = false
    @Published var isProcessingGoogle = false
    @Published var isProcessingApple = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isLoading = false
    
    // MARK: - Dependencies
    private let authManager: AuthManager
    
    // MARK: - Initialization
    init(authManager: AuthManager = AuthManager()) {
        self.authManager = authManager
    }
    
    // MARK: - Public Methods
    func handleEmailInput() {
        validateEmail()
    }
    
    // Firebase Google Sign In
    func handleGoogleLogin() async {
        isProcessingGoogle = true
        defer { isProcessingGoogle = false }
        
        do {
            // 实现 Google 登录
            // 等待 AuthManager 添加相关方法
            // try await authManager.signInWithGoogle()
        } catch {
            showAlert = true
            alertMessage = error.localizedDescription
        }
    }
    
    // Firebase Apple Sign In
    func handleAppleLogin() async {
        isProcessingApple = true
        defer { isProcessingApple = false }
        
        do {
            // 实现 Apple 登录
            // 等待 AuthManager 添加相关方法
            // try await authManager.signInWithApple()
        } catch {
            showAlert = true
            alertMessage = error.localizedDescription
        }
    }
    
    // MARK: - Private Methods
    private func validateEmail() {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        isValid = emailPredicate.evaluate(with: emailOrPhone)
    }
}
