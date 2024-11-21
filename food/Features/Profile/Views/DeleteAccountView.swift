//
//  DeleteAccountView.swift
//  food
//
//  Created by toyousoft on 2024/11/12.
//

import SwiftUI

// 账户删除状态管理
final class DeleteAccountState: ObservableObject {
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var showConfirmation: Bool = false
    @Published var isSuccess: Bool = false  // 添加成功标志
    
    var isValid: Bool {
        !password.isEmpty
    }
    
    func clearFields() {
        password = ""
    }
}

struct DeleteAccountView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var navigationManager: AppNavigationManager
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var accountState = DeleteAccountState()
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 警告信息
                    warningMessage
                    
                    // 密码输入框
                    passwordField
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
            }
            Spacer()
        }
        .navigationTitle("删除账户")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            leading: backButton,
            trailing: deleteButton
        )
        .navigationBarBackButtonHidden(true)
        .alert("提示", isPresented: $accountState.showAlert) {
                  Button("确定") {
                      if accountState.isSuccess {
                          resetUIAfterDeletion()
                      } else if !accountState.alertMessage.contains("错误") {
                          presentationMode.wrappedValue.dismiss()
                      }
                  }
              } message: {
                  Text(accountState.alertMessage)
              }
        .alert("确认删除", isPresented: $accountState.showConfirmation) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                Task {
                    await handleDeleteAccount()
                }
            }
        } message: {
            Text("删除账户后将无法恢复，是否确认删除？")
        }
        .overlay {
            if accountState.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .overlay {
                        ProgressView()
                            .tint(.white)
                    }
            }
        }
    }
    // 重置 UI
    private func resetUIAfterDeletion() {
        // 只保留重置状态的部分
        accountState.clearFields()
        navigationManager.resetNavigation()
    }
    
    private var warningMessage: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("⚠️ 警告")
                .font(.headline)
                .foregroundColor(.red)
            
            Text("账户删除后：")
                .font(.subheadline)
                .foregroundColor(.black)
            
            Text("• 所有数据将被永久删除\n• 操作无法撤销\n• 需要重新注册才能使用服务")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var passwordField: some View {
        PasswordField(
            title: "当前密码",
            placeholder: "请输入当前密码以确认删除",
            text: $accountState.password
        )
    }
    
    private var backButton: some View {
        Button(action: { presentationMode.wrappedValue.dismiss() }) {
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.black)
        }
    }
    
    private var deleteButton: some View {
        Button(action: showDeleteConfirmation) {
            Text("删除")
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .foregroundColor(.white)
                .background(accountState.isValid ? Color.red : Color.gray)
                .cornerRadius(25)
        }
        .disabled(!accountState.isValid || accountState.isLoading)
    }
    
    private func showDeleteConfirmation() {
        accountState.showConfirmation = true
    }
    
    private func handleDeleteAccount() async {
        accountState.isLoading = true
       
        do {
            try await authManager.deleteAccount(password: accountState.password)
            
            await MainActor.run {
                accountState.isSuccess = true  // 设置删除成功标志
                accountState.alertMessage = "账户已成功删除"
                accountState.showAlert = true
               
            }
        } catch {
            await MainActor.run {
                accountState.isSuccess = false
                accountState.alertMessage = error.localizedDescription
                accountState.showAlert = true
            }
        }
        
        await MainActor.run {
            accountState.isLoading = false
        }
    }
}

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DeleteAccountView()
                .environmentObject(AuthManager())
                .environmentObject(AppNavigationManager.shared)
                .environmentObject(LocationManager.shared)
        }
    }
}
