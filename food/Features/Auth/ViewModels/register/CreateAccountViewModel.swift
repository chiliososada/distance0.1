//
//  CreateAccountViewModel.swift
//  food
//
//  Created by toyousoft on 2024/11/04.
//

import Foundation
import SwiftUI

final class CreateAccountViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var formData: RegistrationFormData
       @Published var keyboardHeight: CGFloat = 0
       @Published var showAlert = false
       @Published var alertMessage = ""
       @Published var isLoading = false
       @Published var registrationComplete = false
    
    // MARK: - Form Data Structure
    struct RegistrationFormData {
           var name = ""
           var emailOrPhone: String
           var birthday = Date()
           var selectedGender = "男"
           var password = ""
           var confirmPassword = ""
           var isPasswordVisible = false
           
           let genders = ["男", "女", "其他"]
           
           init(emailOrPhone: String) {
               self.emailOrPhone = emailOrPhone
           }
           
           var isValid: Bool {
               !name.isEmpty &&
               !password.isEmpty &&
               password == confirmPassword &&
               password.count >= 8
           }
       }
    
    // MARK: - Dependencies
    private let authManager: AuthManager
    
    // MARK: - Initialization
    init(emailOrPhone: String, authManager: AuthManager = AuthManager()) {
        self.authManager = authManager
        self.formData = RegistrationFormData(emailOrPhone: emailOrPhone)
    }
    
    // MARK: - Public Methods
    @MainActor
       func createAccount() async throws {
           guard formData.isValid else {
               showValidationError()
               return
           }
           
           isLoading = true
           print("Starting signup process with email: \(formData.emailOrPhone)")
           
           do {
               try await authManager.signUp(
                   email: formData.emailOrPhone,
                   password: formData.password,
                   name: formData.name
               )
               print("Signup successful")
               isLoading = false
               registrationComplete = true
           } catch let error as AuthError {
               print("Signup failed with AuthError: \(error.localizedDescription)")
               isLoading = false
               alertMessage = error.localizedDescription
               showAlert = true
               throw error
           } catch {
               print("Signup failed with unknown error: \(error)")
               isLoading = false
               alertMessage = "注册失败：\(error.localizedDescription)"
               showAlert = true
               throw error
           }
       }
    
    // MARK: - Private Methods
    private func showValidationError() {
         if formData.name.isEmpty {
             showError("请输入名字")
         } else if formData.password.count < 8 {
             showError("密码长度必须至少为8位")
         } else if formData.password != formData.confirmPassword {
             showError("两次输入的密码不一致")
         }
     }
    
    private func handleError(_ error: AuthError) {
           switch error {
           case .duplicateEmail:
               alertMessage = "该邮箱已被注册"
           case .weakPassword:
               alertMessage = "密码强度不够，至少需要6个字符"
           default:
               alertMessage = error.errorDescription ?? "注册失败"
           }
           showAlert = true
       }
       
       private func showError(_ message: String) {
           alertMessage = message
           showAlert = true
       }
    
    
//    // MARK: - Keyboard Management
//    func setupKeyboardObservers() {
//            NotificationCenter.default.addObserver(
//                forName: UIResponder.keyboardWillShowNotification,
//                object: nil,
//                queue: .main
//            ) { [weak self] notification in
//                guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
//                self?.keyboardHeight = keyboardFrame.height
//            }
//            
//            NotificationCenter.default.addObserver(
//                forName: UIResponder.keyboardWillHideNotification,
//                object: nil,
//                queue: .main
//            ) { [weak self] _ in
//                self?.keyboardHeight = 0
//            }
//        }
//    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
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
