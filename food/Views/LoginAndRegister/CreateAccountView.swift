import SwiftUI

// MARK: - Constants
private enum Layout {
    static let spacing: CGFloat = 30
    static let titleSize: CGFloat = 28
    static let inputSpacing: CGFloat = 5
    static let horizontalPadding: CGFloat = 20
    static let cornerRadius: CGFloat = 25
   
}

// MARK: - View Model
final class CreateAccountViewModel: ObservableObject {
    @Published var formData = FormData()
    @Published var navigateToVerification = false
    @Published var keyboardHeight: CGFloat = 0
    
    struct FormData {
        var name = ""
        var emailOrPhone = ""
        var birthday = Date()  // 添加生日字段
        var selectedGender = "男"
        var password = ""
        var confirmPassword = ""
        var isPasswordVisible = false
    }
    
    private var keyboardObservers: [NSObjectProtocol] = []
    let genders = ["男", "女", "其他"]
    
    init(emailOrPhone: String) {
            formData.emailOrPhone = emailOrPhone
            setupKeyboardObservers()
        }
    private func setupKeyboardObservers() {
           NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] notification in
               guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
               withAnimation(.easeOut(duration: 0.16)) {
                   self?.keyboardHeight = keyboardFrame.height
               }
           }
           
           NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] _ in
               withAnimation(.easeOut(duration: 0.16)) {
                   self?.keyboardHeight = 0
               }
           }
       }
       
       deinit {
           NotificationCenter.default.removeObserver(self)
       }

}

// MARK: - Main View
struct CreateAccountView: View {
    @StateObject private var viewModel: CreateAccountViewModel
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var focusedField: Field?
    @Namespace private var bottomID
    
    enum Field: Hashable {
        case name, emailOrPhone, password, confirmPassword
    }
    
    init(emailOrPhone: String) {
        _viewModel = StateObject(wrappedValue: CreateAccountViewModel(emailOrPhone: emailOrPhone))
    }
    
    var body: some View {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: Layout.spacing) {
                        titleSection
                        formSection
                        // 添加一个底部标识视图
                        Color.clear.frame(height: 1).id(bottomID)
                    }
                    .padding(.horizontal, Layout.horizontalPadding)
                    .padding(.bottom, viewModel.keyboardHeight > 0 ? viewModel.keyboardHeight - 50 : 0)
                }
                .onChange(of: focusedField) { oldValue, newValue in
                    if newValue == .password || newValue == .confirmPassword {
                        withAnimation(.easeOut(duration: 0.16)) {
                            proxy.scrollTo(bottomID)
                        }
                    }
                }
            }
            .navigationBarItems(leading: backButton, trailing: nextButton)
            .navigationBarBackButtonHidden(true)
            .navigationDestination(
                isPresented: $viewModel.navigateToVerification,
                destination: VerificationView.init
            )
        }
    
    private var titleSection: some View {
        HStack {
            Text("创建你的账号")
                .font(.system(size: Layout.titleSize, weight: .bold))
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.top, Layout.spacing)
    }
    
    private var formSection: some View {
        VStack(spacing: Layout.spacing) {
            FormField(title: "名字") {
                InputField(
                    placeholder: "名字",
                    text: $viewModel.formData.name,
                    systemImage: viewModel.formData.name.isEmpty ? "" : "checkmark.circle.fill",
                    isSecure: false
                )
                .focused($focusedField, equals: .name)
                .submitLabel(.next)
                .onSubmit { focusedField = .emailOrPhone }
            }
            
            FormField(title: "邮箱") {
                InputField(
                    placeholder: "邮箱",
                    text: $viewModel.formData.emailOrPhone,
                    systemImage: "",
                    isSecure: false
                )
                .focused($focusedField, equals: .emailOrPhone)
                .submitLabel(.next)
                .onSubmit { focusedField = .password }
            }
            
            GenderPicker(
                selectedGender: $viewModel.formData.selectedGender,
                genders: viewModel.genders
            )
            
            FormField(title: "出生年月日") {
                BirthdayField(date: $viewModel.formData.birthday)
            }
            
            FormField(title: "密码") {
                PasswordInputField(
                    placeholder: "密码",
                    text: $viewModel.formData.password,
                    isPasswordVisible: $viewModel.formData.isPasswordVisible
                )
                .focused($focusedField, equals: .password)
                .submitLabel(.next)
                .onSubmit { focusedField = .confirmPassword }
            }
            
            FormField(title: "确认密码") {
                PasswordInputField(
                    placeholder: "确认密码",
                    text: $viewModel.formData.confirmPassword,
                    isPasswordVisible: $viewModel.formData.isPasswordVisible
                )
                .focused($focusedField, equals: .confirmPassword)
                .submitLabel(.done)
            }
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
        Button(action: { viewModel.navigateToVerification = true }) {
            Text("下一步")
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .foregroundColor(.white)
                .background(Color.black)
                .cornerRadius(Layout.cornerRadius)
        }
    }
}

// MARK: - Supporting Views
private struct FormField: View {
    let title: String
    let content: () -> any View
    
    init(title: String, @ViewBuilder content: @escaping () -> any View) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.inputSpacing) {
            Text(title)
                .font(.headline)
            AnyView(content())
        }
    }
}

private struct GenderPicker: View {
    @Binding var selectedGender: String
    let genders: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.inputSpacing) {
            Text("性别")
                .font(.headline)
            
            Picker("性别", selection: $selectedGender) {
                ForEach(genders, id: \.self) { gender in
                    Text(gender).tag(gender)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 12)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.horizontal, 10),
                alignment: .bottom
            )
        }
    }
}
private struct BirthdayField: View {
    @Binding var date: Date
    
    private let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let minDate = calendar.date(byAdding: .year, value: -100, to: Date())!
        return minDate...Date()
    }()
    
    var body: some View {
        HStack {
            DatePicker("", selection: $date, in: dateRange, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "zh_CN"))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.3)),
            alignment: .bottom
        )
    }
}
// MARK: - Preview
struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreateAccountView(emailOrPhone: "example@example.com")
                .environmentObject(TabBarManager())
        }
    }
}
