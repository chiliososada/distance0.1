import SwiftUI

struct VerificationView: View {
    @Environment(\.presentationMode) var presentationMode // 用于后退功能
    @State private var code: [String] = Array(repeating: "", count: 6) // 验证码，每个输入框一个字符
    @FocusState private var focusedField: Int? // 用于跟踪当前聚焦的输入框
    @State private var navigateToNextScreen = false // 控制跳转

    var body: some View {
        VStack() {
            // 标题
            HStack {
                Text("我们向你发送了一个代码")
                    .font(.system(size: 28, weight: .bold)) // 调整字体大小
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 30) // 增加顶部空间
            Text("在下面输入以验证\(emailPlaceholder)")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .padding(.top, 8)
                .padding(.horizontal)

            // 验证码输入框
            HStack(spacing: 10) {
                ForEach(0..<6, id: \.self) { index in
                    CodeInputBox(text: $code[index])
                        .focused($focusedField, equals: index) // 聚焦当前输入框
                        .onChange(of: code[index]) { newValue in
                            if newValue.count == 1 { // 如果输入了一位字符，自动切换到下一个框
                                focusedField = index + 1
                            }
                        }
                }
            }
            .padding(.top, 30)

            Spacer()

            // "下一步" 按钮
            Button(action: {
                // 验证码已输入完毕时，执行下一步
                if code.joined().count == 6 {
                    navigateToNextScreen = true
                }
            }) {
                Text("完成")
                    .font(.system(size: 18, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(code.joined().count == 6 ? Color.black : Color.gray)
                    .cornerRadius(25)
            }
            .disabled(code.joined().count != 6) // 只有当验证码输入完毕时才启用
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
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

    // 示例邮箱占位符
    var emailPlaceholder: String {
        return "chiliososada@gmail.com"
    }
}

// 自定义验证码输入框样式
struct CodeInputBox: View {
    @Binding var text: String // 绑定到验证码输入的数组
    var body: some View {
        TextField("", text: $text)
            .font(.system(size: 24, weight: .medium))
            .frame(width: 40, height: 40)
            .multilineTextAlignment(.center) // 文字居中
            .keyboardType(.numberPad) // 数字键盘
            .cornerRadius(8)
            .overlay(Rectangle().frame(height: 2).foregroundColor(.black), alignment: .bottom) // 底部线条
            .onReceive(text.publisher.collect()) { newValue in
                // 限制输入为一位数字
                if newValue.count > 1 {
                    text = String(newValue.last!)
                }
            }
    }
}

//struct VerificationView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            VerificationView()
//                .environmentObject(TabBarManager()) // 注入环境对象
//        }
//    }
//}
