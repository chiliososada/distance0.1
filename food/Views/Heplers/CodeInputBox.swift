//
//  CodeIp.swift
//  food
//
//  Created by toyousoft on 2024/10/17.
//

import SwiftUI


// 自定义验证码输入框样式
struct CodeInputBox: View {
    @Binding var text: String // 绑定到验证码输入的数组
    var body: some View {
        TextField("", text: $text)
            .font(.system(size: 24, weight: .medium))
            .frame(width: 40, height: 40)
            .multilineTextAlignment(.center) // 文字居中
            .keyboardType(.numberPad) // 数字键盘
            .cornerRadius(8)
            .overlay(Rectangle().frame(height: 2).foregroundColor(.black), alignment: .bottom) // 底部线条
            .onReceive(text.publisher.collect()) { newValue in
                // 限制输入为一位数字
                if newValue.count > 1 {
                    text = String(newValue.last!)
                }
            }
    }
}
