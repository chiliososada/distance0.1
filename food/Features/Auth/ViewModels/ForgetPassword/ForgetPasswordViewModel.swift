import SwiftUI
import FirebaseAuth

@MainActor
class ForgetPasswordViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var isResetEmailSent: Bool = false
    
    // 邮箱验证逻辑，返回验证结果
    func validateEmail() -> Bool {
        // 如果邮箱为空
        if email.isEmpty {
            errorMessage = "请输入电子邮箱"
            showError = true
            return false
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        let isValid = emailPredicate.evaluate(with: email)
        
        if !isValid {
            errorMessage = "请输入有效的电子邮箱地址"
            showError = true
            return false
        }
        
        showError = false
        errorMessage = ""
        return true
    }
    
    func sendPasswordResetEmail() async {
        guard !isLoading else { return }
        
        isLoading = true
        showError = false
        defer { isLoading = false }
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            isResetEmailSent = true
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    private func handleError(_ error: Error) {
        let nsError = error as NSError
        
        switch nsError.code {
        case AuthErrorCode.invalidEmail.rawValue:
            errorMessage = "邮箱格式无效"
        case AuthErrorCode.userNotFound.rawValue:
            errorMessage = "该邮箱未注册"
        case AuthErrorCode.tooManyRequests.rawValue:
            errorMessage = "请求过于频繁，请稍后再试"
        case AuthErrorCode.networkError.rawValue:
            errorMessage = "网络连接错误，请检查网络后重试"
        default:
            errorMessage = "发送重置邮件失败：\(error.localizedDescription)"
        }
        showError = true
    }
}
