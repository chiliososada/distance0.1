import SwiftUI
import Combine

// MARK: - Main View
struct ForgetCodeInputView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = ForgetCodeViewModel()
    @FocusState private var focusedField: Int?
    @State private var navigateToNextScreen = false
    @EnvironmentObject var navigationManager: AppNavigationManager
    let email: String
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    codeInputSection
                    resendSection
                    
                    if viewModel.showError {
                        errorMessage
                    }
                    
                    Spacer(minLength: 40)
                    nextButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
//        .navigationDestination(isPresented: $navigateToNextScreen) {
//            GetNewPasswordView()
//        }
        .overlay {
            if viewModel.isLoading {
                loadingView
            }
        }
    }
    
    // MARK: - UI Components
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("我们已发送代码到你的邮箱")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            
            Text("请输入发送到 \(email) 的代码")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
    }
    
    private var codeInputSection: some View {
        HStack(spacing: 12) {
            ForEach(0..<6, id: \.self) { index in
                CodeInputBox(text: $viewModel.code[index])
                    .frame(height: 50)
                    .focused($focusedField, equals: index)
                    .onChange(of: viewModel.code[index]) {
                        handleCodeInput(index: index, newValue: viewModel.code[index])
                    }
            }
        }
    }
    
    private var resendSection: some View {
        HStack {
            Spacer()
            if viewModel.showResendButton {
                Button("重新发送验证码") {
                    viewModel.resendCode()
                }
                .foregroundColor(.blue)
            } else {
                Text("\(viewModel.countdown)秒后可重新发送")
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }
    
    private var errorMessage: some View {
        Text(viewModel.errorMessage)
            .foregroundColor(.red)
            .font(.footnote)
            .transition(.opacity)
    }
    
    private var nextButton: some View {
        Button(action: handleNextButtonTap) {
            Text("下一步")
                .font(.system(size: 18, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(viewModel.validateCode() ? Color.black : Color.gray.opacity(0.5))
                .cornerRadius(25)
        }
        .disabled(!viewModel.validateCode())
    }
    
    private var backButton: some View {
        Button(action: { presentationMode.wrappedValue.dismiss() }) {
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.black)
        }
    }
    
    private var loadingView: some View {
        ZStack {
            Color.black.opacity(0.4)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // MARK: - Helper Methods
    private func handleCodeInput(index: Int, newValue: String) {
        // 处理输入
        if newValue.count > 1 {
            viewModel.code[index] = String(newValue.suffix(1))
        }
        
        // 自动前进到下一个输入框
        if !newValue.isEmpty && index < 5 {
            focusedField = index + 1
        }
        
        // 处理删除键
        if newValue.isEmpty && index > 0 {
            focusedField = index - 1
        }
        
        viewModel.showError = false
    }
    
    private func handleNextButtonTap() {
        guard viewModel.validateCode() else { return }
        
        viewModel.isLoading = true
        // 模拟网络请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            viewModel.isLoading = false
            navigationManager.navigate(to: .getNewPassword)
        }
    }
}



// MARK: - Preview
struct ForgetCodeInputView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ForgetCodeInputView(email: "example@example.com")
        }
    }
}
