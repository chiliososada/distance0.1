import Foundation
import SwiftUI

@MainActor
final class CreateAccountViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var keyboardHeight: CGFloat = 0
    @Published var formData: RegistrationFormData
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isLoading = false
    //@Published var registrationComplete = false
    @Published var registrationEmail: String?  // 添加这个来跟踪注册邮箱
    // MARK: - Dependencies
    private let authManager: AuthManager
    // MARK: - Form Data Structure
    struct RegistrationFormData {
        var name = ""
        var emailOrPhone: String
        var birthday = Date()
        var selectedGender = "男"
        var password = ""
        var confirmPassword = ""
        var isPasswordVisible = false
        
        let genders = ["男", "女", "その他"]
        
        init(emailOrPhone: String) {
            self.emailOrPhone = emailOrPhone
        }
        
        var isValid: Bool {
            !name.isEmpty &&
            !password.isEmpty &&
            password == confirmPassword &&
            password.count >= AppConstants.Validation.minPasswordLength &&
            isEmailValid
        }
        
        private var isEmailValid: Bool {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            return emailPredicate.evaluate(with: emailOrPhone)
        }
    }
    
    // MARK: - Dependencies

    
    // MARK: - Initialization
    init(emailOrPhone: String, authManager: AuthManager) {
         self.formData = RegistrationFormData(emailOrPhone: emailOrPhone)
         self.authManager = authManager
     }
    
    // MARK: - Public Methods
   
    @MainActor
        func createAccount() async throws {
            guard validateForm() else { return }
            isLoading = true
            defer {
                        isLoading = false
            }
                    
            
            do {
                print("Starting account creation for: \(formData.emailOrPhone)")
                
                let registrationData = RegistrationData(
                    email: formData.emailOrPhone,
                    password: formData.password,
                    name: formData.name
                )
                
                // 执行注册
                try await authManager.signUp(with: registrationData)
                try? await Task.sleep(nanoseconds: 1_000_000_000)// 给状态一点时间更新
                // 注册成功后，记录邮箱用于后续验证
                self.registrationEmail = formData.emailOrPhone
                
            } catch let error as AuthError {
                print("Auth error occurred: \(error.localizedDescription)")
                handleAuthError(error)
                throw error
            } catch {
                print("Unexpected error: \(error.localizedDescription)")
                handleError(error)
                throw error
            }
            
            isLoading = false
        }
        
        private func handleAuthError(_ error: AuthError) {
            alertMessage = error.errorDescription ?? "注册失败"
            showAlert = true
        }
        
        private func handleError(_ error: Error) {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    
    // MARK: - Form Validation Methods
    private func validateForm() -> Bool {
        guard !formData.name.isEmpty else {
            showError("请输入姓名")
            return false
        }
        
        guard formData.password.count >= AppConstants.Validation.minPasswordLength else {
            showError("密码长度必须至少为\(AppConstants.Validation.minPasswordLength)位")
            return false
        }
        
        guard formData.password == formData.confirmPassword else {
            showError("两次输入的密码不一致")
            return false
        }
        
        guard isEmailValid(formData.emailOrPhone) else {
            showError("请输入有效的电子邮箱地址")
            return false
        }
        
        return true
    }
    
    private func isEmailValid(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private func showError(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}

// MARK: - Computed Properties
extension CreateAccountViewModel {
    var name: String {
        get { formData.name }
        set { formData.name = newValue }
    }
    
    var password: String {
        get { formData.password }
        set { formData.password = newValue }
    }
    
    var confirmPassword: String {
        get { formData.confirmPassword }
        set { formData.confirmPassword = newValue }
    }
    
    var isPasswordVisible: Bool {
        get { formData.isPasswordVisible }
        set { formData.isPasswordVisible = newValue }
    }
}


