import SwiftUI

// MARK: - 设置状态管理
final class PersonSettingsState: ObservableObject {
    @Published var cacheSize: String = "1.7M"
    let appVersion: String = "1.2.8(171)"
    
    private let authManager: AuthManager
    private let navigationManager: AppNavigationManager
    private let tabBarManager: TabBarManager
    
    init(authManager: AuthManager,
         navigationManager: AppNavigationManager = .shared,
         tabBarManager: TabBarManager) {
        self.authManager = authManager
        self.navigationManager = navigationManager
        self.tabBarManager = tabBarManager
    }
    
    func clearCache() {
        cacheSize = "0M"
    }
    
    func checkUpdate() {
    }
    
    @MainActor
    func logout() {
        do {
            // 首先调用 Firebase 登出
            try authManager.signOut()
            
            // 重置所有状态
            authManager.updateStateOnMain()
            navigationManager.resetNavigation()
            tabBarManager.resetNavigationState()
            
            // 重置窗口根视图
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
        } catch {
            print("Logout error: \(error.localizedDescription)")
        }
    }
    
    @MainActor
        func deleteAccount() {
            // 这里可以添加删除账户的具体逻辑
            do {
                // 如果有特定的删除账户 API，先调用它
                // try await deleteUserAccount()
                
                // 然后执行登出操作
                logout()
            } catch {
                print("Account deletion error: \(error.localizedDescription)")
            }
        }
}

// MARK: - 设置项组件
struct PersonSettingRow<Content: View>: View {
    let title: String
    let titleColor: Color
    let action: (() -> Void)?
    let trailing: Content
    
    init(
        title: String,
        titleColor: Color = .primary,
        action: (() -> Void)? = nil,
        @ViewBuilder trailing: () -> Content
    ) {
        self.title = title
        self.titleColor = titleColor
        self.action = action
        self.trailing = trailing()
    }
    
    var body: some View {
        if let action = action {
            Button(action: action) {
                rowContent
            }
        } else {
            rowContent
        }
    }
    
    private var rowContent: some View {
        HStack {
            Text(title)
                .foregroundColor(titleColor)
            Spacer()
            trailing
        }
        .padding(.vertical, 10)
    }
}

// MARK: - 主视图
struct PersonSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var navigationManager: AppNavigationManager
    @EnvironmentObject var tabBarManager: TabBarManager
    @StateObject private var settingsState: PersonSettingsState
    @State private var showLogoutConfirmation = false
    @State private var showDeleteAccountConfirmation = false
    
    init() {
        _settingsState = StateObject(wrappedValue: PersonSettingsState(
            authManager: AuthManager(),
            navigationManager: .shared,
            tabBarManager: TabBarManager()
        ))
    }
    
    var body: some View {
        VStack {
            List {
                generalSettingsSection
                accountSettingsSection
            }
            .listStyle(.plain)
        }
        .navigationTitle("个人设置")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .confirmationDialog(
            "确认退出",
            isPresented: $showLogoutConfirmation,
            titleVisibility: .visible
        ) {
            Button("退出登录", role: .destructive) {
                Task { @MainActor in
                    settingsState.logout()
                }
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("确定要退出登录吗？")
        }
        .confirmationDialog(
            "确认注销账户",
            isPresented: $showDeleteAccountConfirmation,
            titleVisibility: .visible
        ) {
            Button("注销账户", role: .destructive) {
                Task { @MainActor in
                    settingsState.deleteAccount()
                }
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("注销账户后将无法恢复，确定要继续吗？")
        }
    }
    
    private var generalSettingsSection: some View {
        Section {
            NavigationLink(destination: PasswordChangeView()) {
                PersonSettingRow(title: "修改密码") {
                    EmptyView()
                }
            }
            
            PersonSettingRow(
                title: "清除缓存",
                action: settingsState.clearCache
            ) {
                Text(settingsState.cacheSize)
                    .foregroundColor(.gray)
            }
            
            PersonSettingRow(
                title: "检测更新",
                action: settingsState.checkUpdate
            ) {
                Text(settingsState.appVersion)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var accountSettingsSection: some View {
        Section {
            PersonSettingRow(
                title: "注销账户",
                titleColor: .red,
                action: { showDeleteAccountConfirmation = true }
            ) {
                EmptyView()
            }
            
            PersonSettingRow(
                title: "退出",
                action: { showLogoutConfirmation = true }
            ) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var backButton: some View {
        Button(action: { presentationMode.wrappedValue.dismiss() }) {
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.black)
        }
    }
}

// MARK: - Previews
struct SettingsView_Previews: PreviewProvider {
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
