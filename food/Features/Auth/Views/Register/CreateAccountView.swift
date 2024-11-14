import SwiftUI
import FirebaseAuth


// MARK: - CreateAccountView
struct CreateAccountView: View {
    // MARK: - Properties
       @Environment(\.dismiss) private var dismiss
       @StateObject private var viewModel: CreateAccountViewModel
       @Environment(\.presentationMode) var presentationMode
       @EnvironmentObject var tabBarManager: TabBarManager
       @FocusState private var focusedField: Field?
       @EnvironmentObject var navigationManager: AppNavigationManager
       @EnvironmentObject var authManager: AuthManager
    
    // MARK: - Focus Fields
    enum Field: Hashable {
        case name
        case emailOrPhone
        case password
        case confirmPassword
    }
    enum Layout {
        static let spacing: CGFloat = 30
        static let titleSize: CGFloat = 28
        static let inputSpacing: CGFloat = 5
        static let horizontalPadding: CGFloat = 20
        static let cornerRadius: CGFloat = 25
      
    }
 
    
 
    // MARK: - Initialization
    init(emailOrPhone: String) {
         
           _viewModel = StateObject(wrappedValue: CreateAccountViewModel(
               emailOrPhone: emailOrPhone,
               authManager: AuthManager()
           ))
       }
       
    // MARK: - Body
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: Layout.spacing) {
                    titleSection
                    formSection
                }
                .padding(.horizontal, Layout.horizontalPadding)
                .padding(.bottom, viewModel.keyboardHeight > 0 ? viewModel.keyboardHeight - 50 : 0)
                
                Color.clear.frame(height: 1).id("bottom")
            }
            .onChange(of: focusedField) {
                if focusedField == .password || focusedField == .confirmPassword {
                    withAnimation {
                        proxy.scrollTo("bottom")
                    }
                }
            }
        }
        .navigationBarItems(leading: backButton, trailing: nextButton)
        .navigationBarBackButtonHidden(true)
        .alert("提示", isPresented: $viewModel.showAlert) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
        .overlay {
                   if viewModel.isLoading {
                       loadingView
                   }
               }
    }
    
    // MARK: - View Components
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
                    text: Binding(
                        get: { viewModel.formData.name },
                        set: { viewModel.formData.name = $0 }
                    ),
                    systemImage: !viewModel.formData.name.isEmpty ? "checkmark.circle.fill" : "",
                    isSecure: false
                )
                .focused($focusedField, equals: .name)
                .submitLabel(.next)
                .onSubmit { focusedField = .emailOrPhone }
            }
            
            FormField(title: "邮箱") {
                InputField(
                    placeholder: "邮箱",
                    text: .constant(viewModel.formData.emailOrPhone),
                    systemImage: "",
                    isSecure: false
                )
                .disabled(true)
            }
            
            genderPicker
            birthdayPicker
            
            // 在密码相关的输入字段中
            FormField(title: "密码") {
                PasswordInputField(
                    placeholder: "密码",
                    text: Binding(
                        get: { viewModel.formData.password },
                        set: { viewModel.formData.password = $0 }
                    ),
                    isPasswordVisible: Binding(
                        get: { viewModel.formData.isPasswordVisible },
                        set: { viewModel.formData.isPasswordVisible = $0 }
                    )
                )
                .focused($focusedField, equals: .password)
                .submitLabel(.next)
                .onSubmit { focusedField = .confirmPassword }
            }

            FormField(title: "确认密码") {
                PasswordInputField(
                    placeholder: "确认密码",
                    text: Binding(
                        get: { viewModel.formData.confirmPassword },
                        set: { viewModel.formData.confirmPassword = $0 }
                    ),
                    isPasswordVisible: Binding(
                        get: { viewModel.formData.isPasswordVisible },
                        set: { viewModel.formData.isPasswordVisible = $0 }
                    )
                )
                .focused($focusedField, equals: .confirmPassword)
                .submitLabel(.done)
            }
        }
    }
    
    private var genderPicker: some View {
        VStack(alignment: .leading, spacing: Layout.inputSpacing) {
            Text("性别")
                .font(.headline)
            
            Picker("性别", selection: Binding(
                get: { viewModel.formData.selectedGender },
                set: { viewModel.formData.selectedGender = $0 }
            )) {
                ForEach(viewModel.formData.genders, id: \.self) { gender in
                    Text(gender)
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
    
    private var birthdayPicker: some View {
        VStack(alignment: .leading, spacing: Layout.inputSpacing) {
            Text("出生年月")
                .font(.headline)
            
            DatePicker(
                "生日",
                selection: Binding(
                    get: { viewModel.formData.birthday },
                    set: { viewModel.formData.birthday = $0 }
                ),
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .environment(\.locale, Locale(identifier: "zh_CN"))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.3)),
                alignment: .bottom
            )
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
        Button {
            Task {
                await handleNextButtonTap()
            }
        } label: {
            Text("下一步")
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .foregroundColor(.white)
                .background(viewModel.formData.isValid ? Color.black : Color.gray)
                .cornerRadius(25)
        }
        .disabled(!viewModel.formData.isValid || viewModel.isLoading)
    }
    
    private var loadingView: some View {
           ZStack {
               Color.black.opacity(0.4)
               ProgressView()
                   .progressViewStyle(CircularProgressViewStyle(tint: .white))
                   .scaleEffect(1.5)
           }
           .edgesIgnoringSafeArea(.all)
       }
    
    
    private func handleNextButtonTap() async {
         do {
             try await viewModel.createAccount()
             
             await MainActor.run {
                 if let email = viewModel.registrationEmail {
                     print("Successfully registered, navigating to verification for: \(email)")
                     navigationManager.navigate(to: .verification(email: email))
                 } else if let user = authManager.currentUser, !user.isEmailVerified {
                     print("Using current user email for verification: \(user.email ?? "")")
                     navigationManager.navigate(to: .verification(email: user.email ?? ""))
                 } else {
                     print("No email available for verification")
                 }
             }
         } catch {
             print("Registration flow error: \(error.localizedDescription)")
         }
     }

}

// MARK: - FormField Component
private struct FormField<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
            content()
        }
    }
}
// MARK: - Preview
struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CreateAccountView(emailOrPhone: "example@example.com")
                .environmentObject(TabBarManager())
        }
    }
}
