import SwiftUI

// 底部按钮组件
struct PasswordChangedView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var tabBarManager: TabBarManager
    @EnvironmentObject var navigationManager: AppNavigationManager
    @StateObject private var viewModel = PasswordChangedViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            contentView
            loginButton
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .overlay {
            if viewModel.isLoading {
                loadingView
            }
        }
        .alert("错误", isPresented: $viewModel.showError) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 30) {
                messageSection
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .frame(maxHeight: .infinity)
        }
    }
    
    private var messageSection: some View {
        HStack {
            Text("你的新密码已经修改成功，现在可以登录了。")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 30)
    }
    
    private var loginButton: some View {
        Button(action: handleLogin) {
            Text("登录")
                .font(.system(size: 18, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.black)
                .cornerRadius(25)
        }
        .disabled(viewModel.isLoading)
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    private var loadingView: some View {
        ZStack {
            Color.black.opacity(0.4)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func handleLogin() {
        Task {
            do {
                viewModel.isLoading = true
                let success = try await viewModel.performAutoLogin()
                
                if success {
                    // 重置导航状态
                    navigationManager.resetNavigation()
                    
                    // 切换到主页
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        let homeView = HomeView()
                            .environmentObject(navigationManager)
                            .environmentObject(tabBarManager)
                        
                        // 使用过渡动画
                        withAnimation(.easeInOut(duration: 0.3)) {
                            window.rootViewController = UIHostingController(rootView: homeView)
                        }
                        window.makeKeyAndVisible()
                    }
                } else {
                    viewModel.showError = true
                    viewModel.errorMessage = "自动登录失败，请手动登录"
                }
            } catch {
                viewModel.showError = true
                viewModel.errorMessage = error.localizedDescription
            }
            
            viewModel.isLoading = false
        }
    }
}
// MARK: - Preview
struct PasswordChangedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PasswordChangedView()
                .environmentObject(TabBarManager())
        }
    }
}
