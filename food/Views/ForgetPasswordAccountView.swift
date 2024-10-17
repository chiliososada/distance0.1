//
//  ForgetPasswordAccountView.swift
//  food
//
//  Created by toyousoft on 2024/10/17.
//

import SwiftUI

struct ForgetPasswordAccountView: View {
    @Environment(\.presentationMode) var presentationMode // 用于后退功能
    @State private var emailOrPhone: String = "" // 输入框内容
    @State private var isNextEnabled: Bool = false // 控制下一步按钮是否启用
    @State private var navigateToCreatePassword = false // 控制跳转
    @State private var email: String = ""
   
    @EnvironmentObject var tabBarManager: TabBarManager
    var body: some View {
        ZStack {
            ScrollView { // 使用 ScrollView 包裹内容
                VStack(spacing: 30) { // 使用更大的 spacing 来美化布局
                    // 标题
                    HStack {
                        Text("查找你的账号，请先输入你的电子邮箱")
                            .font(.system(size: 28, weight: .bold)) // 调整字体大小
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 30) // 增加顶部空间
                    
                    // 电子邮箱输入框
                    InputField(placeholder: "电子邮箱", text: $email, systemImage: email.isEmpty ? "" : "checkmark.circle.fill", isSecure: false)
                        .submitLabel(.done)  // 键盘上显示 "Done" 按钮
                    
                    Spacer() // This pushes内容 upward
                }
                .padding(.horizontal, 20)
                .background(Color.white)
                
            }}
           .ignoresSafeArea(.keyboard) // 避免键盘遮挡内容
           .background(Color.white)
           .navigationBarBackButtonHidden(true) // 隐藏默认的返回按钮
           .navigationBarItems(
            leading: Button(action: {
                presentationMode.wrappedValue.dismiss() // 后退功能
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
            },
            trailing: NavigationLink(destination: FoundEmailView(email: email).environmentObject(tabBarManager)) {
               
                    Text("下一步")
                        .font(.system(size: 12, weight: .medium)) // 调整字体大小为 8
                        .padding(.horizontal, 16) // 调整左右内边距
                        .padding(.vertical, 6) // 调整上下内边距
                        .foregroundColor(.white)
                        .background(Color.black)
                        .cornerRadius(25) // 调整圆角大小
                
            }
        )
    }
}
struct ForgetPasswordAccountView_Previews: PreviewProvider {
    static var previews: some View {
        ForgetPasswordAccountView()
            .environmentObject(TabBarManager()) // 注入环境对象
    }
}
