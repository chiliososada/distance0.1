import SwiftUI

struct GetNewPasswordView: View {
    @Environment(\.presentationMode) var presentationMode // 用于后退功能
   
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var keyboardHeight: CGFloat = 0
    @State private var isPasswordVisible: Bool = false // 控制密码是否可见
    @FocusState private var focusedField: Field? // 用于管理焦点状态
    
    @State private var navigateToPasswordChanged = false // 控制跳转
    
    // 定义表单中的字段
    enum Field: Hashable {
        case password
        case confirmPassword
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 30) {
                    // 标题
                    HStack {
                        Text("请选择你的密码")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 30)
                    
                    // 小字文本
                    Text("确保你的新密码至少包含 8 个字符。尝试在其中使用数字、字母和标点符号，以便创建一个更安全的密码")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    // 密码输入框
                    PasswordInputField(placeholder: "密码", text: $password, isPasswordVisible: $isPasswordVisible)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .confirmPassword }
                    
                    // 确认密码输入框
                    PasswordInputField(placeholder: "确认密码", text: $confirmPassword, isPasswordVisible: $isPasswordVisible)
                        .focused($focusedField, equals: .confirmPassword)
                        .submitLabel(.done)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, keyboardHeight)
                .background(Color.white)
            }
            .ignoresSafeArea(.keyboard)
            .onAppear {
                setupKeyboardObservers()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: {
                presentationMode.wrappedValue.dismiss() // 后退功能
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
            },
            trailing: Button(action: {
                if passwordsAreValid() {
                    navigateToPasswordChanged = true // 手动控制跳转
                }
            }) {
                Text("下一步")
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .foregroundColor(.white)
                    .background(passwordsAreValid() ? Color.black : Color.gray)
                    .cornerRadius(25)
            }
        )
        .navigationDestination(isPresented: $navigateToPasswordChanged) {
            PasswordChangedView()  // 跳转到密码已更改页面
                .environmentObject(TabBarManager()) // 注入环境对象
        }
    }
    
    // 检查密码是否有效的逻辑
    private func passwordsAreValid() -> Bool {
        return password == confirmPassword && password.count >= 8
    }
    
    // 设置键盘显示和隐藏的通知观察者
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation {
                    self.keyboardHeight = keyboardFrame.height - 20
                }
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation {
                self.keyboardHeight = 0
            }
        }
    }
}

struct GetNewPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GetNewPasswordView()
                .environmentObject(TabBarManager()) // 注入环境对象
        }
    }
}
