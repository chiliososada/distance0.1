import SwiftUI
import FirebaseAuth
import Combine

final class VerificationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showResendButton = false
    @Published var countdown: Int = 0
    @Published var remainingAttempts = 5
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var userID: String? // 存储用户ID
    
    private let email: String
    
    // MARK: - Constants
    private enum Constants {
        static let resendInterval = 60 // 建议的最小重发间隔
        static let maxAttemptsPerHour = 5 // Firebase 每小时最大尝试次数
    }
    
    // MARK: - Initialization
    init(user: User?, email: String) {
        self.userID = user?.uid
        self.email = email
        print("ViewModel initialized with userID: \(user?.uid ?? "none")")
        startCountdown()
    }
    
    // MARK: - Public Methods
    @MainActor
    func verifyEmail() async throws -> Bool {
        print("Starting verification process...")
        print("Stored userID: \(userID ?? "none")")
        
        // 直接使用 currentUser
        guard let user = Auth.auth().currentUser else {
            print("No user found in verifyEmail")
            errorMessage = "用户未登录"
            showError = true
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // 多次尝试验证
            for attempt in 1...3 {
                print("Verification attempt \(attempt) for user: \(user.uid)")
                
                try await user.reload()
                
                // 重新获取用户状态
                if let freshUser = Auth.auth().currentUser, freshUser.isEmailVerified {
                    print("Email verified successfully for user: \(freshUser.uid)")
                    userID = freshUser.uid  // 更新存储的用户ID
                    return true
                }
                
                if attempt < 3 {
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                }
            }
            
            errorMessage = "邮箱尚未验证，请查看邮箱并点击验证链接"
            showError = true
            return false
            
        } catch {
            print("Verification error: \(error)")
            handleError(error)
            return false
        }
    }
    
    @MainActor
    func resendVerificationEmail() async {
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "用户未登录"
            showError = true
            return
        }
        
        guard remainingAttempts > 0 else {
            errorMessage = "已达到重发次数限制，请稍后再试"
            showError = true
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await currentUser.sendEmailVerification()
            remainingAttempts -= 1
            startCountdown()
            
            if remainingAttempts == 0 {
                scheduleAttemptsReset()
            }
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Private Methods
    private func handleError(_ error: Error) {
        let nsError = error as NSError
        print("Handling error: \(error.localizedDescription)")
        
        switch nsError.code {
        case AuthErrorCode.invalidEmail.rawValue:
            errorMessage = "邮箱格式无效"
        case AuthErrorCode.tooManyRequests.rawValue:
            errorMessage = "发送请求过于频繁，请稍后再试"
        case AuthErrorCode.userNotFound.rawValue:
            errorMessage = "用户不存在"
        case AuthErrorCode.networkError.rawValue:
            errorMessage = "网络连接错误，请检查网络后重试"
        default:
            errorMessage = "操作失败：\(error.localizedDescription)"
        }
        
        showError = true
    }
    
    private func scheduleAttemptsReset() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3600) { [weak self] in
            self?.remainingAttempts = Constants.maxAttemptsPerHour
        }
    }
    
    // MARK: - Timer Management
    func startCountdown() {
        countdown = Constants.resendInterval
        showResendButton = false
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.countdown > 0 {
                self.countdown -= 1
            } else {
                self.showResendButton = self.remainingAttempts > 0
                self.timer?.invalidate()
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
