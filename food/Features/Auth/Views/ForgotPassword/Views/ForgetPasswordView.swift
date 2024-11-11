import SwiftUI

struct ForgetPasswordView: View {
    @StateObject private var viewModel = ForgetPasswordViewModel()
    @EnvironmentObject var navigationManager: AppNavigationManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("忘记密码")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("请输入您的账号邮箱，我们将向您发送重置密码的链接")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top)
            
            // Email Input
            VStack(alignment: .leading, spacing: 8) {
                TextField("电子邮箱", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled(true)
                    .disabled(viewModel.isLoading)
                
                if viewModel.showError {
                    Text(viewModel.errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal)
            
            // Submit Button
            Button {
                Task {
                    if viewModel.validateEmail() {  // 点击时验证邮箱
                        await viewModel.sendPasswordResetEmail()
                    }
                }
            } label: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 5)
                    }
                    Text(viewModel.isLoading ? "发送中..." : "发送重置链接")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)  // 移除条件背景色
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(viewModel.isLoading)  // 只在加载时禁用按钮
            
            Spacer()
        }
        .alert("邮件已发送", isPresented: $viewModel.isResetEmailSent) {
            Button("确定", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("请查看您的邮箱，点击邮件中的链接来重置密码")
        }
        .alert("发送失败", isPresented: $viewModel.showError) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .navigationBarTitleDisplayMode(.inline)
        .disabled(viewModel.isLoading)
    }
}

struct ForgetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ForgetPasswordView()
                .environmentObject(AppNavigationManager.shared)
        }
    }
}
