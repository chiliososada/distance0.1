import SwiftUI


struct GetNewPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var inputState = PasswordInputStateViewModel()
    
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var focusedField: Field?
    @State private var navigateToPasswordChanged = false
    
    enum Field: Hashable {
        case password
        case confirmPassword
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                contentView
                    .padding(.horizontal, 20)
                    .padding(.bottom, keyboardHeight)
                    .background(Color.white)
            }
            .onChange(of: focusedField) {
                withAnimation {
                    proxy.scrollTo(focusedField, anchor: .center)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton, trailing: nextButton)
        .navigationDestination(isPresented: $navigateToPasswordChanged) {
            PasswordChangedView()
                .environmentObject(TabBarManager())
        }
        .onAppear(perform: setupKeyboardObservers)
    }
    
    private var contentView: some View {
        VStack(spacing: 30) {
            titleSection
            descriptionSection
            passwordFields
            Spacer()
        }
    }
    
    private var titleSection: some View {
        HStack {
            Text("请选择你的密码")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 30)
    }
    
    private var descriptionSection: some View {
        Text("确保你的新密码至少包含 8 个字符。尝试在其中使用数字、字母和标点符号，以便创建一个更安全的密码")
            .font(.system(size: 16))
            .foregroundColor(.gray)
            .padding(.horizontal)
    }
    
    private var passwordFields: some View {
        VStack(spacing: 20) {
            PasswordInputField(
                placeholder: "密码",
                text: $inputState.password,
                isPasswordVisible: $inputState.isPasswordVisible
            )
            .focused($focusedField, equals: .password)
            .submitLabel(.next)
            .onSubmit { focusedField = .confirmPassword }
            
            PasswordInputField(
                placeholder: "确认密码",
                text: $inputState.confirmPassword,
                isPasswordVisible: $inputState.isPasswordVisible
            )
            .focused($focusedField, equals: .confirmPassword)
            .submitLabel(.done)
        }
    }
    
    private var backButton: some View {
        Button(action: { presentationMode.wrappedValue.dismiss() }) {
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.black)
        }
    }
    
    private var nextButton: some View {
        Button(action: { if inputState.isValid { navigateToPasswordChanged = true } }) {
            Text("下一步")
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .foregroundColor(.white)
                .background(inputState.isValid ? Color.black : Color.gray)
                .cornerRadius(25)
        }
    }
    
    private func setupKeyboardObservers() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            
            withAnimation {
                self.keyboardHeight = keyboardFrame.height - 20
            }
        }
        
        notificationCenter.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
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
                .environmentObject(TabBarManager())
        }
    }
}
