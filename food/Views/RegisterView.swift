import SwiftUI

struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode // 用于后退功能
    @State private var emailOrPhone: String = ""
    @State private var navigateToCreateAccount = false // 控制跳转

    var body: some View {
        VStack(spacing: 20) {
            ScrollView { // 使用 ScrollView 包裹内容
                // 标题
                HStack {
                    Text("开始注册Distance吧")
                        .font(.system(size: 28, weight: .bold)) // 调整字体大小
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 30) // 增加顶部空间
                .padding(.bottom, 40)
                // Google 登录按钮
                Button(action: {
                    print("Google Login tapped")
                }) {
                    HStack {
                        Image("google")
                            .resizable()
                            .frame(width: 24, height: 24)
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
                            .foregroundColor(.black)
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
                        RoundedRectangle(cornerRadius: 10) // 添加圆角的边框
                            .stroke(Color.black, lineWidth: 1) // 设置边框颜色为黑色，宽度为 1
                    )
                    .padding(.horizontal)
                    .submitLabel(.done) // Return 键显示为 "Done"
                   
                
                // "下一步" 按钮
                NavigationLink(destination: CreateAccountView(emailOrPhone: emailOrPhone), isActive: $navigateToCreateAccount) {
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
                }
                
                // 忘记密码按钮
                Button(action: {
                    print("Forgot password tapped")
                }) {
                    Text("忘记密码?")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                }
                .padding(.top)
                
                Spacer()
            }}
        .background(Color.white)
        .navigationBarBackButtonHidden(true) // 隐藏默认返回按钮
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
        NavigationView { // 添加 NavigationView 以便能够展示导航功能
            RegisterView()
        }
    }
}
