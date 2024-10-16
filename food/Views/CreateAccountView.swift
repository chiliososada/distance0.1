import SwiftUI

struct CreateAccountView: View {
    @Environment(\.presentationMode) var presentationMode // 用于后退功能
    @State private var name: String = ""
    @State var emailOrPhone: String // 通过初始化器传递邮箱或手机号
    @State private var birthdate: Date = Date() // 使用 Date 类型
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var navigateToCreateEmailCode = false // 控制跳转
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var focusedField: Field? // 用于管理焦点状态

    // 定义表单中的字段
    enum Field: Hashable {
        case name
        case emailOrPhone
        case password
        case confirmPassword
    }

    init(emailOrPhone: String) {
        self._emailOrPhone = State(initialValue: emailOrPhone)
    }

    var body: some View {
        ZStack {
            ScrollView { // 使用 ScrollView 包裹内容
                VStack(spacing: 30) { // 使用更大的 spacing 来美化布局
                    // 标题
                    HStack {
                        Text("创建你的账号")
                            .font(.system(size: 28, weight: .bold)) // 调整字体大小
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 30) // 增加顶部空间
                    
                    // 名字输入框
                    InputField(placeholder: "名字", text: $name, systemImage: name.isEmpty ? "" : "checkmark.circle.fill", isSecure: false)
                        .focused($focusedField, equals: .name) // 聚焦状态
                        .submitLabel(.next) // Return 键显示为 "Next"
                        .onSubmit { focusedField = .emailOrPhone } // 切换到下一个输入框
                    
                    // 手机号码或邮箱输入框（传递的邮箱地址显示在此）
                    InputField(placeholder: "手机号码或邮箱", text: $emailOrPhone, systemImage: "", isSecure: false)
                        .focused($focusedField, equals: .emailOrPhone) // 聚焦状态
                        .submitLabel(.next) // Return 键显示为 "Next"
                        .onSubmit { focusedField = .password } // 切换到下一个输入框
                    
                    // 出生日期选择器
                    HStack {
                        DatePicker("出生日期", selection: $birthdate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .font(.system(size: 18))
                            .padding(.vertical, 12)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    .overlay(Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.5)).padding(.horizontal, 10), alignment: .bottom)
                    
                    // 密码输入框
                    InputField(placeholder: "密码", text: $password, systemImage: "", isSecure: true)
                        .focused($focusedField, equals: .password) // 聚焦状态
                        .submitLabel(.next) // Return 键显示为 "Next"
                        .onSubmit { focusedField = .confirmPassword } // 切换到下一个输入框
                    
                    // 确认密码输入框
                    InputField(placeholder: "确认密码", text: $confirmPassword, systemImage: "", isSecure: true)
                        .focused($focusedField, equals: .confirmPassword) // 聚焦状态
                        .submitLabel(.done) // 最后的输入框显示 "Done"
                    
                    Spacer() // This pushes内容 upward
                }
                .padding(.horizontal, 20)
                .background(Color.white)
                .padding(.bottom, keyboardHeight) // Adjust content padding based on keyboard height
            }
            .ignoresSafeArea(.keyboard) // 避免键盘遮挡内容
            .onAppear {
                // 监听键盘事件
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        withAnimation {
                            self.keyboardHeight = keyboardFrame.height - 20 // 适当减少一些偏移量，确保输入框可见
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
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: {
                presentationMode.wrappedValue.dismiss() // 后退功能
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
            },
            trailing: NavigationLink(destination: VerificationView(), isActive: $navigateToCreateEmailCode) {
                Button(action: {
                    navigateToCreateEmailCode = true
                }) {
                    Text("下一步")
                        .font(.system(size: 12, weight: .medium)) // 调整字体大小为 8
                        .padding(.horizontal, 16) // 调整左右内边距
                        .padding(.vertical, 6) // 调整上下内边距
                        .foregroundColor(.white)
                        .background(Color.black)
                        .cornerRadius(25) // 调整圆角大小
                }
            }
        )
    }
}

// 自定义输入框组件
struct InputField: View {
    var placeholder: String
    @Binding var text: String
    var systemImage: String
    var isSecure: Bool

    var body: some View {
        HStack {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 18))
                    .padding(.vertical, 12)
                    .foregroundColor(.black)
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 18))
                    .padding(.vertical, 12)
                    .foregroundColor(.black)
            }

            // 如果有图标，则显示
            if !systemImage.isEmpty {
                Image(systemName: systemImage)
                    .foregroundColor(.black)
                    .font(.system(size: 20))
            }
        }
        .padding(.horizontal)
        .overlay(Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.5)).padding(.horizontal, 10), alignment: .bottom)
    }
}

struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreateAccountView(emailOrPhone: "example@example.com")
        }
    }
}
