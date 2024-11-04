import SwiftUI

struct LoginPasswordView: View {
    // MARK: - Properties
    @StateObject private var viewModel: LoginPasswordViewModel
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var tabBarManager: TabBarManager
    
    // MARK: - Initialization
    init(emailOrUsername: String) {
        _viewModel = StateObject(wrappedValue: LoginPasswordViewModel(emailOrUsername: emailOrUsername))
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                titleSection
                emailSection
                passwordSection
                Spacer()
                loginSection
                forgotPasswordButton
            }
            .padding(.horizontal, 20)
            .onChange(of: viewModel.authData.password) { 
                viewModel.validatePassword()
            }
        }
        .ignoresSafeArea(.keyboard)
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .navigationDestination(isPresented: $viewModel.navigateToForgetPassword) {
            ForgetPasswordAccountView()
                .environmentObject(tabBarManager)
        }
    }
    
    // MARK: - View Components
    private var titleSection: some View {
        HStack {
            Text("接下来，请输入你的密码")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 30)
    }
    
    private var emailSection: some View {
        HStack {
            Text(viewModel.emailOrUsername)
                .font(.system(size: 18))
                .padding(.vertical, 12)
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.horizontal)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.5))
                .padding(.horizontal, 10),
            alignment: .bottom
        )
    }
    
    private var passwordSection: some View {
        LoginPasswordInputField(
            text: $viewModel.authData.password,
            isVisible: $viewModel.authData.isPasswordVisible,
            placeholder: "密码"
        )
    }
    
    private var loginSection: some View {
        Button {
            Task {
                await viewModel.login()
                if case .success = viewModel.authState {
                    viewModel.updateRootView(tabBarManager: tabBarManager)
                }
            }
        } label: {
            Text("登录")
                .font(.system(size: 18, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(viewModel.isLoginEnabled ? Color.black : Color.gray)
                .cornerRadius(25)
        }
        .disabled(!viewModel.isLoginEnabled)
        .padding(.horizontal)
    }
    
    private var forgotPasswordButton: some View {
        Button(action: { viewModel.navigateToForgetPassword = true }) {
            Text("忘记密码?")
                .font(.system(size: 14))
                .foregroundColor(.blue)
        }
        .padding(.horizontal)
    }
    
    private var backButton: some View {
        Button(action: { presentationMode.wrappedValue.dismiss() }) {
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.black)
        }
    }
}

// MARK: - Preview
struct LoginPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LoginPasswordView(emailOrUsername: "example@example.com")
                .environmentObject(TabBarManager())
        }
    }
}
