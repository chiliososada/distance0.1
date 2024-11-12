import SwiftUI
// MARK: - 主视图
struct PersonSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var navigationManager: AppNavigationManager
    @EnvironmentObject var tabBarManager: TabBarManager
    @StateObject private var settingsState: PersonSettingsViewModel
    @State private var showLogoutConfirmation = false
   
    
    init() {
        _settingsState = StateObject(wrappedValue: PersonSettingsViewModel(
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
            NavigationLink(destination: DeleteAccountView()) {
                PersonSettingRow(title: "删除账户", titleColor: .red) {
                    EmptyView()
                }
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
