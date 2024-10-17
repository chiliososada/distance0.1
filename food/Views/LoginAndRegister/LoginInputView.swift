import SwiftUI

struct LoginInputView: View {
    @Environment(\.presentationMode) var presentationMode // 用于后退功能
    @State private var email: String = "" // 输入框内容
    @State private var navigateToNextStep = false // 控制跳转到下一步页面
    var showBackButton: Bool // 动态控制是否显示返回按钮
    
    @EnvironmentObject var tabBarManager: TabBarManager

    var body: some View {
        ZStack {
            ScrollView { // 使用 ScrollView 包裹内容
                VStack(spacing: 30) {
                    // 标题
                    HStack {
                        Text("要开始登录，请先输入你的邮箱")
                            .font(.system(size: 28, weight: .bold)) // 调整字体大小
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 30) // 增加顶部空间
                    
                    // 电子邮箱输入框
                    InputField(placeholder: "电子邮箱", text: $email, systemImage: email.isEmpty ? "" : "checkmark.circle.fill", isSecure: false)
                        .submitLabel(.done)  // 键盘上显示 "Done" 按钮
                        .onChange(of: email) { 
                            // 监听邮箱内容的变化并启用或禁用“下一步”按钮
                            isNextEnabled = !email.isEmpty
                        }
                    
                    Spacer() // Pushes content upward

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
                 
                }
                .padding(.horizontal, 20)
                .background(Color.white)
                
            }}
           .ignoresSafeArea(.keyboard) // 避免键盘遮挡内容
           .background(Color.white)
           .navigationBarBackButtonHidden(true) // 隐藏默认的返回按钮
           .navigationBarItems(
            leading: showBackButton ? Button(action: {
                          presentationMode.wrappedValue.dismiss() // 后退功能
                      }) {
                          Image(systemName: "arrow.left")
                              .font(.system(size: 20, weight: .medium))
                              .foregroundColor(.black)
                      } : nil,
            trailing: Button(action: {
                navigateToNextStep = true // 设置跳转
            }) {
                Text("下一步")
                    .font(.system(size: 12, weight: .medium)) // 调整字体大小
                    .padding(.horizontal, 16) // 调整左右内边距
                    .padding(.vertical, 6) // 调整上下内边距
                    .foregroundColor(.white)
                    .background(isNextEnabled ? Color.black : Color.gray) // 动态背景颜色
                    .cornerRadius(25) // 调整圆角大小
            }
            .disabled(!isNextEnabled) // 按钮禁用状态
        )
        
        .navigationDestination(isPresented: $navigateToNextStep) {
            LoginPasswordView(emailOrUsername: email)
                .environmentObject(tabBarManager) // 注入环境对象并跳转
        }
    }
    
    // 是否启用“下一步”按钮
    @State private var isNextEnabled: Bool = false
}

struct LoginInputView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LoginInputView(showBackButton: true)
                .environmentObject(TabBarManager()) // 注入环境对象
        }
    }
}
