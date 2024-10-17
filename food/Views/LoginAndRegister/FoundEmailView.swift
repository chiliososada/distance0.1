import SwiftUI

struct FoundEmailView: View {
    @Environment(\.presentationMode) var presentationMode // 用于后退功能
    @State var email: String // 从上一个页面传递过来的电子邮箱
    @EnvironmentObject var tabBarManager: TabBarManager
    @State private var navigateToCodeInput = false // 控制跳转

    var body: some View {
        ZStack {
            ScrollView { // 使用 ScrollView 包裹内容
                VStack(spacing: 30) { // 使用更大的 spacing 来美化布局
                    // 标题
                    HStack {
                        Text("请点击下一步，我们将会给你的邮箱发送一个代码。")
                            .font(.system(size: 24, weight: .bold)) // 调整字体大小
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 30) // 增加顶部空间
                    
                    // 显示电子邮箱，不可编辑
                    InputField(placeholder: "电子邮箱", text: .constant(email), systemImage: "checkmark.circle.fill", isSecure: false)
                        .disabled(true) // 设置为不可编辑
                        .submitLabel(.done)  // 键盘上显示 "Done" 按钮
                    
                    Spacer() // Push content upwards
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
                navigateToCodeInput = true
            }) {
                Text("下一步")
                    .font(.system(size: 12, weight: .medium)) // 调整字体大小
                    .padding(.horizontal, 16) // 调整左右内边距
                    .padding(.vertical, 6) // 调整上下内边距
                    .foregroundColor(.white)
                    .background(Color.black)
                    .cornerRadius(25) // 调整圆角大小
            }
            .disabled(email.isEmpty) // 当 email 为空时禁用按钮
        )
        .navigationDestination(isPresented: $navigateToCodeInput) {
            ForgetCodeInputView(email: email)
                .environmentObject(tabBarManager)
        }
    }
}

// 为新页面添加预览
struct FoundEmailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FoundEmailView(email: "example@example.com")
                .environmentObject(TabBarManager()) // 注入环境对象
        }
    }
}
