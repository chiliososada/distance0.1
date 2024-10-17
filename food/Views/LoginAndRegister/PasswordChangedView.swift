import SwiftUI

struct PasswordChangedView: View {
    @Environment(\.presentationMode) var presentationMode // 用于后退功能
    @EnvironmentObject var tabBarManager: TabBarManager
    @State private var navigateToLogin = false // 控制跳转

    var body: some View {
        ZStack {
            ScrollView { // 使用 ScrollView 包裹内容
                VStack(spacing: 30) { // 使用更大的 spacing 来美化布局
                    // 标题
                    HStack {
                        Text("你的新密码已经修改成功，现在可以登录了。")
                            .font(.system(size: 24, weight: .bold)) // 调整字体大小
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 30) // 增加顶部空间
                    
                    Spacer() // Push content upwards
                }
                .padding(.horizontal, 20)
                .background(Color.white)
            }
            .ignoresSafeArea(.keyboard) // 避免键盘遮挡内容
            .background(Color.white)
            .navigationBarBackButtonHidden(true) // 隐藏默认的返回按钮
//            .navigationBarItems(
//                leading: Button(action: {
//                    presentationMode.wrappedValue.dismiss() // 后退功能
//                }) {
//                    Image(systemName: "arrow.left")
//                        .font(.system(size: 20, weight: .medium))
//                        .foregroundColor(.black)
//                }
//            )

            // "登录" 按钮
            VStack {
                Spacer()
                Button(action: {
                    navigateToLogin = true // 点击后跳转到登录页面
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
                .padding(.bottom, 10)
            }
        }
        .navigationDestination(isPresented: $navigateToLogin) {
            LoginInputView(showBackButton: false).environmentObject(tabBarManager) // 修改密码后进入登录页面不需要返回按钮
        }
    }
}

// 为新页面添加预览
struct PasswordChangedView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordChangedView()
            .environmentObject(TabBarManager()) // 注入环境对象
    }
}
