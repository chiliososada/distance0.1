//
//  PasswordChangeView.swift
//  food
//
//  Created by toyousoft on 2024/10/21.
//
import SwiftUI


struct PasswordChangeView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 当前密码输入框
                    VStack(alignment: .leading, spacing: 5) {
                        Text("当前密码")
                            .font(.headline)
                            .foregroundColor(.black)
                        HStack {
                            SecureField("请输入当前密码", text: $currentPassword)
                                .padding(.vertical, 10)
                            Spacer()
                            Button(action: {
                                // 处理忘记密码逻辑
                            }) {
                                Text("忘记密码?")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        .overlay(Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.5)).padding(.horizontal, 10), alignment: .bottom)
                    }
                    
                    // 新密码输入框
                    VStack(alignment: .leading, spacing: 5) {
                        Text("新密码")
                            .font(.headline)
                            .foregroundColor(.black)
                        HStack {
                            SecureField("至少8个字符", text: $newPassword)
                                .padding(.vertical, 10)
                        }
                        .padding(.horizontal)
                        .overlay(Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.5)).padding(.horizontal, 10), alignment: .bottom)
                    }
                    
                    // 确认密码输入框
                    VStack(alignment: .leading, spacing: 5) {
                        Text("确认密码")
                            .font(.headline)
                            .foregroundColor(.black)
                        HStack {
                            SecureField("至少8个字符", text: $confirmPassword)
                                .padding(.vertical, 10)
                        }
                        .padding(.horizontal)
                        .overlay(Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.5)).padding(.horizontal, 10), alignment: .bottom)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
            }
            Spacer()
        }
        .navigationTitle("更新密码")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
            },
            trailing: Button(action: {
               
            }) {
                Text("完成")
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .foregroundColor(.white)
                    .background(Color.black)
                    .cornerRadius(25)
            }
        )
        .navigationBarBackButtonHidden(true) // 隐藏默认返回按钮
    }
}

struct UpdatePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PasswordChangeView()
        }
    }
}
