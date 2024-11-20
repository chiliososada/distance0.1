import SwiftUI

struct LoginPasswordView: View {
    // MARK: - Properties
    @StateObject private var viewModel: LoginPasswordViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navigationManager: AppNavigationManager
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var tabBarManager: TabBarManager
    
    // MARK: - Layout Constants
    private enum Layout {
        static let spacing: CGFloat = 30
        static let horizontalPadding: CGFloat = 20
        static let cornerRadius: CGFloat = 25
        static let buttonHeight: CGFloat = 50
        static let titleSize: CGFloat = 28
    }
    
    // MARK: - Initialization
    init(emailOrUsername: String) {
        _viewModel = StateObject(wrappedValue: LoginPasswordViewModel(
            emailOrUsername: emailOrUsername,
            authManager: AuthManager()
        ))
        print("LoginPasswordVeiw")
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: Layout.spacing) {
                    titleSection
                    emailSection
                    passwordSection
                    Spacer(minLength: Layout.spacing)
                    loginSection
                    forgotPasswordButton
                }
                .padding(.horizontal, Layout.horizontalPadding)
            }
            .background(Color.white)
            .onChange(of: viewModel.authData.password) { _ in
                viewModel.validatePassword()
            }
            
            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .alert("登录失败", isPresented: $viewModel.showError) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    // MARK: - View Components
    private var titleSection: some View {
        HStack {
            Text("接下来，请输入你的密码")
                .font(.system(size: Layout.titleSize, weight: .bold))
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.top, Layout.spacing)
    }
    
    private var emailSection: some View {
        HStack {
            Text(viewModel.authData.email)  // 使用 authData.email
                .font(.system(size: 18))
                .padding(.vertical, 12)
                .foregroundColor(.black)
            Spacer()
        }
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.5))
                .padding(.horizontal, 10),
            alignment: .bottom
        )
    }
    
    private var passwordSection: some View {
        PasswordInputField(
            placeholder: "密码",
            text: $viewModel.authData.password,
            isPasswordVisible: $viewModel.authData.isPasswordVisible
        )
    }
    
    private var loginSection: some View {
        Button(action: handleLogin) {
            ZStack {
                Text("登录")
                    .font(.system(size: 18, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .frame(height: Layout.buttonHeight)
                    .foregroundColor(.white)
                    .background(viewModel.isLoginEnabled ? Color.black : Color.gray)
                    .cornerRadius(Layout.cornerRadius)
            }
        }
        .disabled(!viewModel.isLoginEnabled || viewModel.isLoading)
    }
    
    private var forgotPasswordButton: some View {
        Button(action: {
            navigationManager.navigate(to: .forgetPassword)
        }) {
            Text("忘记密码?")
                .font(.system(size: 14))
                .foregroundColor(.blue)
        }
        .padding(.top, 10)
    }
    
    private var backButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.black)
        }
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Methods
    private func handleLogin() {
        Task {
            await viewModel.login()
            
            if viewModel.loginSuccess {
                // 重置导航状态
                navigationManager.resetNavigation()
                tabBarManager.resetNavigationState()
            }
        }
    }
}

// MARK: - Preview
struct LoginPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LoginPasswordView(emailOrUsername: "example@example.com")
                .environmentObject(AppNavigationManager.shared)
                .environmentObject(AuthManager())
                .environmentObject(TabBarManager())
        }
    }
}
