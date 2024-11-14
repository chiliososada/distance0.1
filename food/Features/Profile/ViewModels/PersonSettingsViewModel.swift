import SwiftUI

@MainActor
final class PersonSettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var cacheSize: String = "1.7M"
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isLoading = false
    @Published var showLogoutConfirmation = false
    
    // MARK: - Constants
    let appVersion: String = "1.2.8(171)"
    
    // MARK: - Dependencies
    private let authManager: AuthManager
    private let navigationManager: AppNavigationManager
    private let tabBarManager: TabBarManager
    private let sessionManager: SessionManager
    
    // MARK: - Initialization
    init(
        authManager: AuthManager,
        navigationManager: AppNavigationManager = .shared,
        tabBarManager: TabBarManager,
        sessionManager: SessionManager = .shared
    ) {
        self.authManager = authManager
        self.navigationManager = navigationManager
        self.tabBarManager = tabBarManager
        self.sessionManager = sessionManager
    }
    
    // MARK: - Public Methods
    
    /// 清除缓存
    func clearCache() async {
        isLoading = true
        defer { isLoading = false }
        // 模拟清除缓存操作
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            cacheSize = "0M"
            showAlert = true
            alertMessage = "缓存已清除"
            isLoading = false
        }
    }
    
    /// 检查更新
    func checkUpdate() async {
        isLoading = true
        defer { isLoading = false }
        // 模拟检查更新操作
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            showAlert = true
            alertMessage = "当前已是最新版本"
            isLoading = false
        }
    }
    
    /// 退出登录
    func logout() async {
          isLoading = true
        defer { isLoading = false }
          do {
              try await authManager.signOut()
              await resetUI()
              
          } catch let error as AuthError {
              showAlert = true
              alertMessage = error.errorDescription ?? "退出登录失败"
          } catch {
              showAlert = true
              alertMessage = "退出登录失败：\(error.localizedDescription)"
          }
          
          isLoading = false
      }
    
    // MARK: - Private Methods
    
    /// 重置UI状态
    private func resetUI() async {
        // 重置导航状态
        navigationManager.resetNavigation()
        tabBarManager.resetNavigationState()
        
        // 重置窗口根视图
        await MainActor.run {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let contentView = ContentView()
                    .environmentObject(authManager)
                    .environmentObject(tabBarManager)
                    .environmentObject(navigationManager)
                    .environmentObject(LocationManager.shared)
                
                window.rootViewController = UIHostingController(rootView: contentView)
                window.makeKeyAndVisible()
            }
        }
    }
    
    /// 处理认证错误
    private func handleError(_ error: AuthError) {
        showAlert = true
        alertMessage = error.errorDescription ?? "操作失败，请稍后重试"
    }
}

// MARK: - Preview Helper
struct PersonSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PersonSettingsView()
                .environmentObject(AuthManager())
                .environmentObject(TabBarManager())
                .environmentObject(AppNavigationManager.shared)
                .environmentObject(LocationManager.shared)
        }
    }
}
