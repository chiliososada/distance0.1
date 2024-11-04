//
//  LoginPasswordInputField.swift
//  food
//
//  Created by toyousoft on 2024/11/04.
//

import SwiftUI

struct LoginPasswordInputField: View {
    // MARK: - Properties
    @Binding var text: String
    @Binding var isVisible: Bool
    let placeholder: String
    
    // MARK: - Constants
    private enum Constants {
        static let fontSize: CGFloat = 18
        static let verticalPadding: CGFloat = 12
        static let borderOpacity: CGFloat = 0.5
    }
    
    // MARK: - Body
    var body: some View {
        HStack {
            Group {
                if isVisible {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .font(.system(size: Constants.fontSize))
            .padding(.vertical, Constants.verticalPadding)
            .foregroundColor(.black)
            .disableAutocorrection(true)
            .submitLabel(.done)
            
            // 切换密码可见性的按钮
            Button(action: {
                withAnimation(.easeInOut) {
                    isVisible.toggle()
                }
            }) {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(Constants.borderOpacity))
                .padding(.horizontal, 10),
            alignment: .bottom
        )
    }
}

// MARK: - Preview
struct LoginPasswordInputField_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 普通状态
            LoginPasswordInputField(
                text: .constant(""),
                isVisible: .constant(false),
                placeholder: "请输入密码"
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Empty Password")
            
            // 输入状态
            LoginPasswordInputField(
                text: .constant("password123"),
                isVisible: .constant(true),
                placeholder: "请输入密码"
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("With Password")
        }
    }
}
