import SwiftUI

struct LoginPasswordView: View {
    @Environment(\.presentationMode) var presentationMode // 用于后退功能
    @State private var password: String = "" // 密码输入框内容
    @State private var isPasswordVisible: Bool = false // 控制密码是否可见
    @State private var isLoginEnabled: Bool = false // 控制登录按钮是否启用
    @State private var navigateToForgetPassword = false // 控制忘记密码页面的跳转
    var emailOrUsername: String // 邮件或用户名传递进来
    
    @EnvironmentObject var tabBarManager: TabBarManager

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 30) {
                    // 标题
                    HStack {
                        Text("接下来，请输入你的密码")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 30)
                    
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
                                .submitLabel(.done)
                        } else {
                            SecureField("密码", text: $password)
                                .font(.system(size: 18))
                                .padding(.vertical, 12)
                                .foregroundColor(.black)
                                .disableAutocorrection(true)
                                .submitLabel(.done)
                        }
                        
                        // 显示/隐藏密码按钮
                        Button(action: {
                            withAnimation(.easeInOut) {
                                isPasswordVisible.toggle()
                            }
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    .overlay(Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.5)).padding(.horizontal, 10), alignment: .bottom)
                    
                    Spacer()

                    // "登录" 按钮
                    Button(action: {
                        goToHomeView() // 触发跳转
                    }) {
                        Text("登录")
                            .font(.system(size: 18, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(isLoginEnabled ? Color.black : Color.gray)
                            .cornerRadius(25)
                    }
                    .padding(.horizontal)
                    .disabled(!isLoginEnabled)

                    // 忘记密码按钮
                    Button(action: {
                        navigateToForgetPassword = true // 设置为 true 来触发导航
                    }) {
                        Text("忘记密码?")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    .navigationDestination(isPresented: $navigateToForgetPassword) {
                        ForgetPasswordAccountView()
                            .environmentObject(tabBarManager) // 注入环境对象
                    }
                }
                .padding(.horizontal, 20)
                .onChange(of: password) {
                     isLoginEnabled = !password.isEmpty // 直接访问 password
                            }
                .background(Color.white)
            }
        }
        .ignoresSafeArea(.keyboard)
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
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
        NavigationStack {
            LoginPasswordView(emailOrUsername: "example@example.com")
                .environmentObject(TabBarManager()) // 注入环境对象
        }
    }
}
