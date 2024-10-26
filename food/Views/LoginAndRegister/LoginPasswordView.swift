import SwiftUI

// 密码登录状态管理
final class LoginPasswordState: ObservableObject {
    @Published var password: String = ""
    @Published var isPasswordVisible: Bool = false
    @Published var isLoginEnabled: Bool = false
    
    func validatePassword() {
        isLoginEnabled = !password.isEmpty
    }
}

// 密码输入框组件
struct LoginPasswordInputField: View {
    @Binding var text: String
    @Binding var isVisible: Bool
    let placeholder: String
    
    var body: some View {
        HStack {
            Group {
                if isVisible {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .font(.system(size: 18))
            .padding(.vertical, 12)
            .foregroundColor(.black)
            .disableAutocorrection(true)
            .submitLabel(.done)
            
            Button(action: {
                withAnimation(.easeInOut) {
                    isVisible.toggle()
                }
            }) {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
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
}

struct LoginPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var loginState = LoginPasswordState()
    @State private var navigateToForgetPassword = false
    
    let emailOrUsername: String
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var tabBarManager: TabBarManager
    
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
            .onChange(of: loginState.password) {
                loginState.validatePassword()
            }
        }
        .ignoresSafeArea(.keyboard)
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }
    
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
            Text(emailOrUsername)
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
            text: $loginState.password,
            isVisible: $loginState.isPasswordVisible,
            placeholder: "密码"
        )
    }
    
    private var loginSection: some View {
        Button(action: goToHomeView) {
            Text("登录")
                .font(.system(size: 18, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(loginState.isLoginEnabled ? Color.black : Color.gray)
                .cornerRadius(25)
        }
        .padding(.horizontal)
        .disabled(!loginState.isLoginEnabled)
    }
    
    private var forgotPasswordButton: some View {
        Button(action: { navigateToForgetPassword = true }) {
            Text("忘记密码?")
                .font(.system(size: 14))
                .foregroundColor(.blue)
        }
        .padding(.horizontal)
        .navigationDestination(isPresented: $navigateToForgetPassword) {
            ForgetPasswordAccountView()
                .environmentObject(tabBarManager)
        }
    }
    
    private var backButton: some View {
        Button(action: { presentationMode.wrappedValue.dismiss() }) {
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.black)
        }
    }
    
    private func goToHomeView() {
        // 创建用户配置
        let userProfile = AuthManager.UserProfile(
            userId: "用户ID",
            userName: "用户名"
        )
        
        // 保存登录状态和用户信息
        let authManager = AuthManager()
        authManager.signIn(profile: userProfile)
        
        // 切换到主页
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

struct PasswordLoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LoginPasswordView(emailOrUsername: "example@example.com")
                .environmentObject(TabBarManager())
        }
    }
}
