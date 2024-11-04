//
//  RegisterViewModel.swift
//  food
//
//  Created by toyousoft on 2024/11/04.
//

import Foundation
import SwiftUI

final class RegisterViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var emailOrPhone = ""
    @Published var navigateToCreateAccount = false
    @Published var navigateToForgetPassword = false
    
    // MARK: - Validation Properties
    @Published var isValid = false
    @Published var authState: AuthState = .idle
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    // MARK: - Social Login States
    @Published var isProcessingGoogle = false
    @Published var isProcessingApple = false
    
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
    
    func handleGoogleLogin() {
        isProcessingGoogle = true
        // 模拟网络请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.isProcessingGoogle = false
            // 处理Google登录逻辑
        }
    }
    
    func handleAppleLogin() {
        isProcessingApple = true
        // 模拟网络请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.isProcessingApple = false
            // 处理Apple登录逻辑
        }
    }
    
    // MARK: - Private Methods
    private func validateEmail() {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        isValid = emailPredicate.evaluate(with: emailOrPhone)
    }
}
