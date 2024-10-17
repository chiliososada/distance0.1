import SwiftUI

struct ForgetPasswordAccountView: View {
    @Environment(\.presentationMode) var presentationMode // 用于后退功能
    @State private var emailOrPhone: String = "" // 输入框内容
    @State private var isNextEnabled: Bool = false // 控制下一步按钮是否启用
    @State private var navigateToFoundEmail = false // 控制跳转
    @State private var email: String = ""
   
    @EnvironmentObject var tabBarManager: TabBarManager

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 30) {
                    // 标题
                    HStack {
                        Text("查找你的账号，请先输入你的电子邮箱")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 30) // 增加顶部空间
                    
                    // 电子邮箱输入框
                    InputField(placeholder: "电子邮箱", text: $email, systemImage: email.isEmpty ? "" : "checkmark.circle.fill", isSecure: false)
                        .onChange(of: email) {
                            isNextEnabled = !email.isEmpty // 直接访问 @State 的 email 变量
                        }
                        .submitLabel(.done)  // 键盘上显示 "Done" 按钮
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .background(Color.white)
            }
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
            },
            trailing: Button(action: {
                if isNextEnabled {
                    navigateToFoundEmail = true // 设置为 true 来触发导航
                }
            }) {
                Text("下一步")
                    .font(.system(size: 12, weight: .medium)) // 调整字体大小
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .foregroundColor(.white)
                    .background(isNextEnabled ? Color.black : Color.gray) // 根据按钮启用状态改变颜色
                    .cornerRadius(25) // 调整圆角大小
            }
            .disabled(!isNextEnabled) // 禁用按钮，直到输入内容有效
        )
        .navigationDestination(isPresented: $navigateToFoundEmail) {
            FoundEmailView(email: email)
                .environmentObject(tabBarManager) // 注入环境对象
        }
    }
}

struct ForgetPasswordAccountView_Previews: PreviewProvider {
    static var previews: some View {
        ForgetPasswordAccountView()
            .environmentObject(TabBarManager()) // 注入环境对象
    }
}
