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
    @State private var isPasswordVisible: Bool = false // 控制密码是否可见
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
            ScrollView {
                VStack(spacing: 30) {
                    // 标题
                    HStack {
                        Text("创建你的账号")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 30)
                    
                    // 名字输入框
                    InputField(placeholder: "名字", text: $name, systemImage: name.isEmpty ? "" : "checkmark.circle.fill", isSecure: false)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .emailOrPhone }
                    
                    // 邮箱输入框
                    InputField(placeholder: "邮箱", text: $emailOrPhone, systemImage: "", isSecure: false)
                        .focused($focusedField, equals: .emailOrPhone)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }
                    
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
                .background(Color.white)
                .padding(.bottom, keyboardHeight)
            }
            .ignoresSafeArea(.keyboard)
            .onAppear {
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
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
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
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .foregroundColor(.white)
                        .background(Color.black)
                        .cornerRadius(25)
                }
            }
        )
    }
}




struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreateAccountView(emailOrPhone: "example@example.com")
        }
    }
}
