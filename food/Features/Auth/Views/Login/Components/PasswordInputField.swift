//
//  PasswordInputField.swift
//  food
//
//  Created by toyousoft on 2024/10/16.
//
import SwiftUI
// 自定义密码输入框，带小眼睛切换功能
struct PasswordInputField: View {
    var placeholder: String
    @Binding var text: String
    @Binding var isPasswordVisible: Bool

    var body: some View {
        HStack {
            if isPasswordVisible {
                TextField(placeholder, text: $text)
                    .font(.system(size: 18))
                    .padding(.vertical, 12)
                    .foregroundColor(.black)
            } else {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 18))
                    .padding(.vertical, 12)
                    .foregroundColor(.black)
            }
            Button(action: {
                isPasswordVisible.toggle() // 切换密码可见状态
            }) {
                Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
        .overlay(Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.5)).padding(.horizontal, 10), alignment: .bottom)
    }
}
