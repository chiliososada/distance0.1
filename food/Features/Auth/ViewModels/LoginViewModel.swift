//
//  LoginViewModel.swift
//  food
//
//  Created by toyousoft on 2024/11/04.
//

import Foundation
import SwiftUI

final class LoginViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var inputData = AuthInputData()
    @Published var authState: AuthState = .idle
    @Published var isLoginEnabled = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    // MARK: - Dependencies
    private let authManager: AuthManager
    
    // MARK: - Initialization
    init(authManager: AuthManager = AuthManager()) {
        self.authManager = authManager
    }
    
    // MARK: - Public Methods
    func validateEmail() {
        isLoginEnabled = inputData.isEmailValid
    }
    
    func validatePassword() {
        isLoginEnabled = !inputData.password.isEmpty
    }
    
    func login() {
        guard inputData.isEmailValid else {
            handleError(.invalidEmail)
            return
        }
        
        guard !inputData.password.isEmpty else {
            handleError(.invalidPassword)
            return
        }
        
        authState = .loading
        
        // 模拟网络请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            // 创建用户配置
            let userProfile = UserProfile(
                userId: "user123",
                userName: self.inputData.email
            )
            
            // 保存登录状态和用户信息
            self.authManager.signIn(profile: userProfile)
            self.authState = .success
        }
    }
    
    // MARK: - Private Methods
    private func handleError(_ error: AuthError) {
        authState = .failure(error)
        showAlert = true
        alertMessage = error.message
    }
}

// MARK: - Preview Helper
extension LoginViewModel {
    static var preview: LoginViewModel {
        let viewModel = LoginViewModel()
        viewModel.inputData.email = "test@example.com"
        return viewModel
    }
}
