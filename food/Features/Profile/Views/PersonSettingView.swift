import SwiftUI

// MARK: - 设置状态管理
final class PersonSettingsState: ObservableObject {
    @Published var cacheSize: String = "1.7M"
    let appVersion: String = "1.2.8(171)"
    
    private let authManager: AuthManager
    
    init(authManager: AuthManager) {
        self.authManager = authManager
    }
    
    func clearCache() {
        // 实现清除缓存的逻辑
        cacheSize = "0M"
    }
    
    func checkUpdate() {
        // 实现检查更新的逻辑
    }
    
    func logout() {
        authManager.signOut()
        navigateToLogin()
    }
    
    func deleteAccount() {
        // 删除账户的 API
        authManager.signOut()
        navigateToLogin()
    }
    
    private func navigateToLogin() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UIHostingController(
                rootView: HomeLoginView()
                    .environmentObject(authManager)
                    .environmentObject(TabBarManager())
            )
            window.makeKeyAndVisible()
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
    @StateObject private var settingsState: PersonSettingsState
    @State private var showLogoutConfirmation = false
    @State private var showDeleteAccountConfirmation = false
    
    
       init(authManager: AuthManager? = nil) {
           // 使用传入的 authManager 或创建一个新的
           let manager = authManager ?? AuthManager()
           _settingsState = StateObject(wrappedValue: PersonSettingsState(authManager: manager))
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
            Button("退出登录", role: .destructive, action: settingsState.logout)
            Button("取消", role: .cancel) {}
        } message: {
            Text("确定要退出登录吗？")
        }
        .confirmationDialog(
            "确认注销账户",
            isPresented: $showDeleteAccountConfirmation,
            titleVisibility: .visible
        ) {
            Button("注销账户", role: .destructive, action: settingsState.deleteAccount)
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
        }
    }
}
