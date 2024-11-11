//
//  LoginViewModel.swift
//  food
//
//  Created by toyousoft on 2024/11/04.
//

import Foundation
import SwiftUI
import FirebaseAuth

final class LoginViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var inputData = AuthInputData()
    @Published var isLoginEnabled = false
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
    
    /// 验证邮箱格式并更新登录按钮状态
    func validateEmail() {
        isLoginEnabled = inputData.isEmailValid
    }
    
    /// 验证邮箱并决定是否可以进行下一步
    /// - Returns: 如果邮箱有效返回true，否则返回false
    func validateAndProceed() -> Bool {
        guard inputData.isEmailValid else {
            alertMessage = "请输入有效的邮箱地址"
            showAlert = true
            return false
        }
        return true
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
