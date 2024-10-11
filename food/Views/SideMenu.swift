import SwiftUI

struct SideMenu: View {
    @Binding var showMenu: Bool

    var body: some View {
        
      
            VStack(alignment: .leading, spacing: 0) {
                // 头像和用户名部分
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
                .padding(.top, 40)

                // 菜单项
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 10) {
                        // Profile按钮
                        MenuItem(title: "Profile", icon: "person.circle", destination: ProfilesView(), showMenu: $showMenu)

                        // Security按钮
                        MenuItem(title: "Security", icon: "shield", destination: SecurityView(), showMenu: $showMenu)

                        Divider()

                        // About App 区域的按钮
                        MenuItem(title: "Privacy Policy", icon: "lock.shield", destination: PrivacyPolicyView(), showMenu: $showMenu)
                        
                        MenuItem(title: "About App", icon: "info.circle", destination: AboutAppView(), showMenu: $showMenu)
                        
                        
                        
                        
                        
                        
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
            }
            .padding(.top)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(width: getRect().width * 0.7)
            .frame(maxHeight: .infinity)
            .background(Color.white.opacity(0.04).ignoresSafeArea(.container, edges: .vertical))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }



@ViewBuilder
func MenuItem(title: String, icon: String, destination: some View, showMenu: Binding<Bool>) -> some View {
    NavigationLink(destination: destination.onAppear {
        withAnimation {
            //showMenu.wrappedValue = false // 点击后关闭 SideMenu
        }
    }) {
        HStack {
            Image(systemName: icon)
                .resizable()
                .frame(width: 22, height: 22)
                .foregroundColor(.black)

            Text(title)
                .font(.headline)
                .foregroundColor(.black)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}

@ViewBuilder
func TabButton(title: String, image: String) -> some View {

    NavigationLink {

        Text("\(title) View")
            .navigationTitle(title)

    } label: {
        HStack(spacing: 14) {
            Image(image)
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fill)
                .frame(width: 22, height: 22)

            Text(title)
        }
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// Profile 页面
struct ProfilesView: View {
    var body: some View {
        VStack {
            Text("Profile Page")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(Color.white)
                .ignoresSafeArea() // 确保忽略安全区域，填充整个屏幕
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea() // 确保忽略安全区域，填充整个屏幕
    }
}

// Security 页面
struct SecurityView: View {
    var body: some View {
        Text("Security Page")
            .font(.largeTitle)
            .navigationTitle("Security") // 设置导航标题
            .navigationBarTitleDisplayMode(.inline)
    }
}

// Language 页面
struct LanguageView: View {
    var body: some View {
        Text("Language Page")
            .font(.largeTitle)
            .navigationTitle("Language") // 设置导航标题
            .navigationBarTitleDisplayMode(.inline)
    }
}

// Privacy Policy 页面
struct PrivacyPolicyView: View {
    var body: some View {
        Text("Privacy Policy Page")
            .font(.largeTitle)
            .navigationTitle("Privacy Policy") // 设置导航标题
            .navigationBarTitleDisplayMode(.inline)
    }
}

// About App 页面
struct AboutAppView: View {
    var body: some View {
        Text("About App Page")
            .font(.largeTitle)
            .navigationTitle("About App") // 设置导航标题
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct SideMenu_Previews: PreviewProvider {
    static var previews: some View {
        SideMenu(showMenu: .constant(true)) // 使用常量绑定来预览菜单
    }
}

// 获取屏幕大小的扩展方法
extension View {
    func getRect() -> CGRect {
        return UIScreen.main.bounds
    }
}
