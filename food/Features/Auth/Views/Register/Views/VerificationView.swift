import SwiftUI
import FirebaseAuth

struct VerificationView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: VerificationViewModel
    @EnvironmentObject var navigationManager: AppNavigationManager
    @EnvironmentObject var tabBarManager: TabBarManager
    @EnvironmentObject var authManager: AuthManager
    let email: String
        
        init(email: String?) {
            let currentUser = Auth.auth().currentUser
            let userEmail = email ?? currentUser?.email ?? ""
            
            print("VerificationView init with userID: \(currentUser?.uid ?? "none")")
            
            self._viewModel = StateObject(wrappedValue: VerificationViewModel(
                user: currentUser,
                email: userEmail
            ))
            self.email = userEmail
        }
    
    
    // MARK: - Body
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                headerSection
                emailInstructionsSection
                resendSection
                Spacer()
                verifyButton
            }
            .padding(.horizontal)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: backButton)
            
            if viewModel.isLoading {
                loadingView
            }
        }
        .alert("验证提示", isPresented: $viewModel.showError) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    // MARK: - UI Components
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("验证你的邮箱")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            
            Text("我们已发送验证邮件到：")
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            Text(email)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 30)
    }
    
    private var emailInstructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("请按以下步骤完成验证：")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    Text("•").foregroundColor(.gray)
                    Text("查看你的邮箱")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                }
                
                HStack(alignment: .top, spacing: 8) {
                    Text("•").foregroundColor(.gray)
                    Text("找到主题为验证你的邮箱的邮件")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                }
                
                HStack(alignment: .top, spacing: 8) {
                    Text("•").foregroundColor(.gray)
                    Text("点击邮件中的验证链接")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                }
                
                HStack(alignment: .top, spacing: 8) {
                    Text("•").foregroundColor(.gray)
                    Text("完成验证后点击下方验证按钮")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                }
            }
            .padding(.leading)
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var resendSection: some View {
        HStack {
            Spacer()
            if viewModel.showResendButton {
                Button("重新发送验证邮件") {
                    Task {
                        await viewModel.resendVerificationEmail()
                    }
                }
                .foregroundColor(.blue)
                if viewModel.remainingAttempts < 5 {
                    Text("(剩余\(viewModel.remainingAttempts)次)")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            } else {
                Text("\(viewModel.countdown)秒后可重新发送")
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }
    
    var verifyButton: some View {
        Button(action: {
            print("Verify button tapped - Current user: \(Auth.auth().currentUser?.uid ?? "none")")
            handleVerificationSubmit()
        }) {
            Text("验证")
                .font(.system(size: 18, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.black)
                .cornerRadius(25)
        }
        .disabled(viewModel.isLoading)
        .padding(.bottom, 10)
    }
    
    private var backButton: some View {
        Button(action: { presentationMode.wrappedValue.dismiss() }) {
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.black)
        }
    }
    
    private var loadingView: some View {
        ZStack {
            Color.black.opacity(0.4)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
        }
        .ignoresSafeArea()
    }
    
    private func handleVerificationSubmit() {
        Task {
            do {
                // 尝试先刷新 AuthManager 状态
                await authManager.refreshUserStatus()
                
                print("Verification button tapped")
                print("Current auth user: \(Auth.auth().currentUser?.uid ?? "none")")
                
                let success = try await viewModel.verifyEmail()
                if success {
                    // 确保认证状态更新
                    await authManager.checkEmailVerification()
                    
                    if authManager.isEmailVerified {
                        await MainActor.run {
                            print("Navigation to home view")
                            navigationManager.resetNavigation()
                            
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first {
                                let homeView = HomeView()
                                    .environmentObject(navigationManager)
                                    .environmentObject(tabBarManager)
                                    .environmentObject(authManager)
                                
                                window.rootViewController = UIHostingController(rootView: homeView)
                                window.makeKeyAndVisible()
                            }
                        }
                    }
                }
            } catch {
                print("Verification error: \(error)")
                viewModel.errorMessage = error.localizedDescription
                viewModel.showError = true
            }
        }
    }
}

// MARK: - Preview
struct VerificationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            VerificationView(email: "example@example.com")
                .environmentObject(TabBarManager())
                .environmentObject(AppNavigationManager.shared)
                .environmentObject(AuthManager())
        }
    }
}
