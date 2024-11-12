import SwiftUI

// 密码更新状态管理
final class PasswordChangeState: ObservableObject {
    @Published var currentPassword: String = ""
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""
    @Published var isPasswordVisible: Bool = false
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    var isValid: Bool {
        !currentPassword.isEmpty &&
        !newPassword.isEmpty &&
        !confirmPassword.isEmpty &&
        newPassword.count >= 8 &&
        newPassword == confirmPassword
    }
    
    func clearFields() {
        currentPassword = ""
        newPassword = ""
        confirmPassword = ""
    }
}

// 自定义密码输入字段组件
struct PasswordField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var trailingContent: (() -> AnyView)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
            
            HStack {
                SecureField(placeholder, text: $text)
                    .padding(.vertical, 10)
                
                if let trailing = trailingContent {
                    trailing()
                }
            }
            .padding(.horizontal)
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

struct PasswordChangeView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var passwordState = PasswordChangeState()
    @StateObject private var authManager = AuthManager()
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    currentPasswordField
                    newPasswordField
                    confirmPasswordField
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
            }
            Spacer()
        }
        .navigationTitle("更新密码")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            leading: backButton,
            trailing: submitButton
        )
        .navigationBarBackButtonHidden(true)
        .alert("提示", isPresented: $passwordState.showAlert) {
            Button("确定") {
                if !passwordState.alertMessage.contains("错误") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } message: {
            Text(passwordState.alertMessage)
        }
        .overlay {
            if passwordState.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .overlay {
                        ProgressView()
                            .tint(.white)
                    }
            }
        }
    }
    
    private var currentPasswordField: some View {
        PasswordField(
            title: "当前密码",
            placeholder: "请输入当前密码",
            text: $passwordState.currentPassword
        )
    }
    
    private var newPasswordField: some View {
        PasswordField(
            title: "新密码",
            placeholder: "至少8个字符",
            text: $passwordState.newPassword
        )
    }
    
    private var confirmPasswordField: some View {
        PasswordField(
            title: "确认密码",
            placeholder: "至少8个字符",
            text: $passwordState.confirmPassword
        )
    }
    
    private var backButton: some View {
        Button(action: { presentationMode.wrappedValue.dismiss() }) {
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.black)
        }
    }
    
    private var submitButton: some View {
        Button(action: handleSubmit) {
            Text("完成")
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .foregroundColor(.white)
                .background(passwordState.isValid ? Color.black : Color.gray)
                .cornerRadius(25)
        }
        .disabled(!passwordState.isValid || passwordState.isLoading)
    }
    
    private func handleSubmit() {
        Task {
            passwordState.isLoading = true
            
            do {
                try await authManager.updatePassword(
                    currentPassword: passwordState.currentPassword,
                    newPassword: passwordState.newPassword
                )
                
                await MainActor.run {
                    passwordState.alertMessage = "密码更新成功"
                    passwordState.showAlert = true
                    passwordState.clearFields()
                }
            } catch {
                await MainActor.run {
                    passwordState.alertMessage = error.localizedDescription
                    passwordState.showAlert = true
                }
            }
            
            await MainActor.run {
                passwordState.isLoading = false
            }
        }
    }
}
// MARK: - Previews
struct UpdatePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PasswordChangeView()
        }
    }
}
