//
//  PasswordInputStateViewModel.swift
//  food
//
//  Created by toyousoft on 2024/11/04.
//
import SwiftUI

final class PasswordInputStateViewModel: ObservableObject {
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isPasswordVisible: Bool = false
    
    var isValid: Bool {
        PasswordValidator.isValid(password, confirmation: confirmPassword)
    }
}
struct PasswordValidator {
    static func isValid(_ password: String, confirmation: String) -> Bool {
        password == confirmation && password.count >= 8
    }
}
