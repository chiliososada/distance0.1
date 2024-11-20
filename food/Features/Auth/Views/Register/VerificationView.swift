import SwiftUI
import FirebaseAuth

struct VerificationView: View {
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: VerificationViewModel
    @EnvironmentObject var navigationManager: AppNavigationManager
    @EnvironmentObject var tabBarManager: TabBarManager
    @EnvironmentObject var authManager: AuthManager
    let email: String
    
    // MARK: - Layout Constants
    private enum Layout {
        static let spacing: CGFloat = 30
        static let horizontalPadding: CGFloat = 20
        static let cornerRadius: CGFloat = 25
        static let buttonHeight: CGFloat = 50
        static let titleSize: CGFloat = 28
    }
    
    // MARK: - Initialization
    init(email: String?) {
        let currentUser = Auth.auth().currentUser
        let userEmail = email ?? currentUser?.email ?? ""
        self.email = userEmail
        self._viewModel = StateObject(wrappedValue: VerificationViewModel(
            user: currentUser,
            email: userEmail
        ))
        print("VerficvationView")
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            VStack(spacing: Layout.spacing) {
                titleSection
                emailInstructionsSection
                resendSection
                Spacer()
                verifyButton
            }
            .padding(.horizontal, Layout.horizontalPadding)
            
            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .alert("验证提示", isPresented: $viewModel.showError) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    // MARK: - View Components
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("验证你的邮箱")
                .font(.system(size: Layout.titleSize, weight: .bold))
                .foregroundColor(.black)
            
            Text("我们已发送验证邮件到：")
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            Text(email)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, Layout.spacing)
    }
    
    private var emailInstructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("请按以下步骤完成验证：")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                instructionRow("查看你的邮箱")
                instructionRow("找到主题为验证你的邮箱的邮件")
                instructionRow("点击邮件中的验证链接")
                instructionRow("完成验证后点击下方验证按钮")
            }
            .padding(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func instructionRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.gray)
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
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
    
    private var verifyButton: some View {
        Button(action: handleVerification) {
            Text("验证")
                .font(.system(size: 18, weight: .medium))
                .frame(maxWidth: .infinity)
                .frame(height: Layout.buttonHeight)
                .foregroundColor(.white)
                .background(Color.black)
                .cornerRadius(Layout.cornerRadius)
        }
        .disabled(viewModel.isLoading)
        .padding(.bottom, 10)
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
    // MARK: - Methods
    private func handleVerification() {
        Task {
            do {
                if try await viewModel.verifyEmail() {
                    print("Email verification successful")
                    
                    // 验证成功后重置导航状态
                    navigationManager.resetNavigation()
                    tabBarManager.resetNavigationState()
                    
                    // 更新窗口根视图
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        let homeView = HomeView()
                            .environmentObject(tabBarManager)
                            .environmentObject(navigationManager)
                            .environmentObject(authManager)
                            .environmentObject(LocationManager.shared)
                        
                        window.rootViewController = UIHostingController(rootView: homeView)
                        window.makeKeyAndVisible()
                    }
                } else {
                    print("Email verification failed")
                    viewModel.showError = true
                    viewModel.errorMessage = "邮箱验证失败，请确保已点击验证链接"
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
