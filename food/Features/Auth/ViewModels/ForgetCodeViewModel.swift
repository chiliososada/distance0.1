//
//  ForgetCodeViewModel.swift
//  food
//
//  Created by toyousoft on 2024/11/04.
//

import SwiftUI


// MARK: - ViewModel
class ForgetCodeViewModel: ObservableObject {
    @Published var code: [String] = Array(repeating: "", count: 6)
    @Published var isLoading: Bool = false
    @Published var showResendButton: Bool = false
    @Published var countdown: Int = 60
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    private var timer: Timer?
    
    init() {
        startCountdown()
    }
    
    func startCountdown() {
        countdown = 60
        showResendButton = false
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.countdown > 0 {
                self.countdown -= 1
            } else {
                self.showResendButton = true
                self.timer?.invalidate()
            }
        }
    }
    
    func resendCode() {
        // 在这里实现重新发送验证码的逻辑
        startCountdown()
    }
    
    func validateCode() -> Bool {
        let fullCode = code.joined()
        guard fullCode.count == 6 else { return false }
        // 这里可以添加其他验证逻辑
        return true
    }
    
    deinit {
        timer?.invalidate()
    }
}
