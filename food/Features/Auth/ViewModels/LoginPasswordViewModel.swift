//
//  LoginPasswordViewModel.swift
//  food
//
//  Created by toyousoft on 2024/11/04.
//

import SwiftUI

final class LoginPasswordViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var authData = AuthInputData()
    @Published var authState: AuthState = .idle
    @Published var isLoginEnabled: Bool = false
    @Published var navigateToForgetPassword = false
    
    // MARK: - Properties
    private let authManager: AuthManager
    let emailOrUsername: String
    
    // MARK: - Initialization
    init(emailOrUsername: String, authManager: AuthManager = AuthManager()) {
        self.emailOrUsername = emailOrUsername
        self.authManager = authManager
    }
    
    // MARK: - Public Methods
    func validatePassword() {
        isLoginEnabled = !authData.password.isEmpty
    }
    
    func login() async {
        guard !authData.password.isEmpty else { return }
        
        authState = .loading
        
        // 模拟网络请求
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // 创建用户配置
        let userProfile = UserProfile(
            userId: "user123",
            userName: emailOrUsername
        )
        
        // 保存登录状态和用户信息
        await MainActor.run {
            authManager.signIn(profile: userProfile)
            authState = .success
        }
    }
    
    // MARK: - Window Management
    func updateRootView(tabBarManager: TabBarManager) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UIHostingController(
                rootView: HomeView()
                    .environmentObject(tabBarManager)
                    .environmentObject(authManager)
            )
            window.makeKeyAndVisible()
        }
    }
}

// MARK: - Preview Helper
extension LoginPasswordViewModel {
    static var preview: LoginPasswordViewModel {
        LoginPasswordViewModel(emailOrUsername: "test@example.com")
    }
}
