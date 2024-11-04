//
//  ForgetPasswordViewModel.swift
//  food
//
//  Created by toyousoft on 2024/11/04.
//

import SwiftUI

// 创建一个 ViewModel 来处理业务逻辑
class ForgetPasswordViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var isEmailValid: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    // 邮箱验证逻辑
    func validateEmail() {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        isEmailValid = emailPredicate.evaluate(with: email)
        
        if !email.isEmpty && !isEmailValid {
            errorMessage = "请输入有效的电子邮箱地址"
            showError = true
        } else {
            showError = false
        }
    }
}
