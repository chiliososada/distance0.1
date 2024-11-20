import SwiftUI

struct SideMenu: View {
    @Binding var showMenu: Bool
    @EnvironmentObject private var navigationManager: AppNavigationManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 头像和用户信息部分
            VStack(alignment: .center, spacing: 14) {
                Image("sample1")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 65, height: 65)
                    .clipShape(Circle())
                    .frame(maxWidth: .infinity)
                
                VStack(spacing: 8) {
                    Text("Liu ziyuan")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text("加入日: 2024年10月7日")
                        .font(.callout)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(.top, horizontalSizeClass == .regular ? 20 : 40)
            
            // 菜单项列表
            VStack(alignment: .leading, spacing: 24) {
                Button {
                    handleNavigation(to: .profileEditor)
                } label: {
                    MenuItemView(title: "Profile", icon: "person.circle")
                }
                .buttonStyle(MenuButtonStyle())
                
                Button {
                    handleNavigation(to: .settings)
                } label: {
                    MenuItemView(title: "Setting", icon: "shield")
                }
                .buttonStyle(MenuButtonStyle())
                
                Divider()
                    .padding(.vertical, 8)
                
                Button {
                    handleNavigation(to: .privacyPolicy)
                } label: {
                    MenuItemView(title: "Privacy Policy", icon: "lock.shield")
                }
                .buttonStyle(MenuButtonStyle())
                
                Button {
                    handleNavigation(to: .about)
                } label: {
                    MenuItemView(title: "About App", icon: "info.circle")
                }
                .buttonStyle(MenuButtonStyle())
            }
            .padding(.top, 32)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white)
    }
    
    private func handleNavigation(to route: AppRoute) {
        print("Navigating to: \(route)") // 调试日志
        // 先关闭菜单
        withAnimation(.easeOut(duration: 0.3)) {
            showMenu = false
        }
        // 等待菜单关闭动画完成后再导航
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            navigationManager.resetNavigation()
            navigationManager.navigate(to: route)
        }
    }
}

// MARK: - Menu Item View
struct MenuItemView: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.primary)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.7))
        }
        .contentShape(Rectangle()) // 确保整个区域可点击
    }
}

// MARK: - Custom Button Style
struct MenuButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 8)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Preview Provider
struct SideMenu_Previews: PreviewProvider {
    static var previews: some View {
        SideMenu(showMenu: .constant(true))
            .environmentObject(AppNavigationManager.shared)
            .previewLayout(.sizeThatFits)
    }
}
