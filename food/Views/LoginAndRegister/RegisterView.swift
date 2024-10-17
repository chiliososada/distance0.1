import SwiftUI

struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode // 用于后退功能
    @State private var emailOrPhone: String = ""
    @State private var navigateToCreateAccount = false // 控制跳转
    @State private var navigateToForgetPassword = false // 控制跳转到忘记密码
    @EnvironmentObject var tabBarManager: TabBarManager
    
    var body: some View {
        VStack(spacing: 20) {
            ScrollView {
                // 标题
                HStack {
                    Text("开始注册Distance吧")
                        .font(.system(size: 28, weight: .bold)) // 调整字体大小
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 30)
                .padding(.bottom, 40)

                // Google 登录按钮
                Button(action: {
                    print("Google Login tapped")
                }) {
                    HStack {
                        Image("google")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.gray)
                        Text("使用 Google 账号登录")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(25)
                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                }
                .padding(.horizontal)

                // Apple 登录按钮
                Button(action: {
                    print("Apple Login tapped")
                }) {
                    HStack {
                        Image(systemName: "applelogo")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                        Text("使用 Apple 登录")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(25)
                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                }
                .padding(.horizontal)
                .padding(.bottom, 20)

                // 分割线和 "或" 文本
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.5))
                    Text("或")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.5))
                }
                .padding(.horizontal)

                // 输入框
                TextField("邮件地址", text: $emailOrPhone)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .submitLabel(.done)
                
                // "下一步" 按钮
                Button(action: {
                    navigateToCreateAccount = true // 设置跳转
                }) {
                    Text("下一步")
                        .font(.system(size: 18, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.black)
                        .cornerRadius(25)
                }
                .padding(.horizontal)
                .navigationDestination(isPresented: $navigateToCreateAccount) {
                    CreateAccountView(emailOrPhone: emailOrPhone) // 跳转到下一个页面
                }

                // 优化后的 "忘记密码?" 按钮
                Button(action: {
                    navigateToForgetPassword = true // 设置跳转到忘记密码
                }) {
                    Text("忘记密码?")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                }
                .padding(.top)
                .padding(.horizontal)
                .navigationDestination(isPresented: $navigateToForgetPassword) {
                    ForgetPasswordAccountView()
                        .environmentObject(tabBarManager) // 跳转到忘记密码页面并注入环境对象
                }
            }
        }
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
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView().environmentObject(TabBarManager())
    }
}
