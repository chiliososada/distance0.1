//
//  InputText.swift
//  food
//
//  Created by toyousoft on 2024/10/16.
//
import SwiftUI
// 自定义输入框组件
struct InputField: View {
    var placeholder: String
    @Binding var text: String
    var systemImage: String
    var isSecure: Bool

    var body: some View {
        HStack {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 18))
                    .padding(.vertical, 12)
                    .foregroundColor(.black)
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 18))
                    .padding(.vertical, 12)
                    .foregroundColor(.black)
            }

            // 如果有图标，则显示
            if !systemImage.isEmpty {
                Image(systemName: systemImage)
                    .foregroundColor(.black)
                    .font(.system(size: 20))
            }
        }
        .padding(.horizontal)
        .overlay(Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.5)).padding(.horizontal, 10), alignment: .bottom)
    }
}
