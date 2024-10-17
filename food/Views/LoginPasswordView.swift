import SwiftUI

struct LoginPasswordView: View {
    @Environment(\.presentationMode) var presentationMode // 用于后退功能
    @State private var password: String = "" // 密码输入框内容
    @State private var isPasswordVisible: Bool = false // 控制密码是否可见
    @State private var isLoginEnabled: Bool = false // 控制登录按钮是否启用
    @State private var navigateToHome = false // 控制跳转到主页
    var emailOrUsername: String // 邮件或用户名传递进来
   
    
    //aa
    @State private var isViewTabBarHidden = false
    @EnvironmentObject var tabBarManager: TabBarManager

    var body: some View {
        ZStack {
            ScrollView { // 使用 ScrollView 包裹内容
                VStack(spacing: 30) { // 使用更大的 spacing 来美化布局
                    // 标题
                    HStack {
                        Text("接下来，请输入你的密码")
                            .font(.system(size: 28, weight: .bold)) // 调整字体大小
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 30) // 增加顶部空间
                    
                    // 邮箱显示（不可编辑）
                    HStack {
                        Text(emailOrUsername)
                            .font(.system(size: 18))
                            .padding(.vertical, 12)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .overlay(Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.5)).padding(.horizontal, 10), alignment: .bottom)
                    
                    // 密码输入框
                    HStack {
                        if isPasswordVisible {
                            TextField("密码", text: $password)
                                .font(.system(size: 18))
                                .padding(.vertical, 12)
                                .foregroundColor(.black)
                                .disableAutocorrection(true)
                                .submitLabel(.done) // 最后的输入框显示 "Done"
                        } else {
                            SecureField("密码", text: $password)
                                .font(.system(size: 18))
                                .padding(.vertical, 12)
                                .foregroundColor(.black)
                                .disableAutocorrection(true)
                                .submitLabel(.done) // 最后的输入框显示 "Done"
                        }
                        
                        // 显示/隐藏密码按钮
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    .overlay(Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.5)).padding(.horizontal, 10), alignment: .bottom)
                    
                    Spacer() // This pushes内容 upward

                    // "登录" 按钮
                    Button(action: {
                        // 触发跳转到 HomeView 并关闭当前视图栈
                        goToHomeView()
                    }) {
                        Text("登录")
                            .font(.system(size: 18, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.black)
                            .cornerRadius(25)
                    }
                    .padding(.horizontal)
                    
                    // 忘记密码按钮
                    NavigationLink(destination: ForgetPasswordAccountView().environmentObject(tabBarManager)) {
                        Text("忘记密码?")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                    }
                   
                    .padding(.horizontal)
                   
                }
                .padding(.horizontal, 20)
                .background(Color.white)
            }
            Spacer()
        }
        .ignoresSafeArea(.keyboard) // 避免键盘遮挡内容
        .background(Color.white)
        .navigationBarBackButtonHidden(true) // 隐藏默认的返回按钮
        .navigationBarItems(
            leading: Button(action: {
                presentationMode.wrappedValue.dismiss() // 后退功能
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
            }
        )
    }
    
    func goToHomeView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                window.rootViewController = UIHostingController(rootView: HomeView().environmentObject(tabBarManager))
                window.makeKeyAndVisible()
            }
        }
    }
}

struct PasswordLoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LoginPasswordView(emailOrUsername: "example@example.com")
                .environmentObject(TabBarManager()) // 注入环境对象
        }
    }
}
