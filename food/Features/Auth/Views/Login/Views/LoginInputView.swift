import SwiftUI

struct LoginInputView: View {
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var navigationManager: AppNavigationManager
    @State private var navigateToNextStep = false
    
    let showBackButton: Bool
    // 自定义的 init 方法 可以删除用于测试导航
      init(showBackButton: Bool) {
          self.showBackButton = showBackButton
          print("LoginInputView")
      }
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                titleSection
                emailInputSection
                if showBackButton {
                    socialLoginButtons
                }
            }
            .padding(.horizontal, 20)
            .background(Color.white)
        }
        .ignoresSafeArea(.keyboard)
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: backButton,
            trailing: nextButton
        )
        .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {}
    }
    
    // MARK: - View Components
    private var titleSection: some View {
        HStack {
            Text("要开始登录，请先输入你的邮箱")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 30)
    }
    
    private var emailInputSection: some View {
        InputField(
            placeholder: "电子邮箱",
            text: $viewModel.inputData.email,
            systemImage: viewModel.inputData.isEmailValid ? "checkmark.circle.fill" : "",
            isSecure: false
        )
        .submitLabel(.done)
        .onChange(of: viewModel.inputData.email) { 
            viewModel.validateEmail()
        }
    }
    
    private var socialLoginButtons: some View {
        VStack(spacing: 20) {
            SocialLoginButton(
                icon: "google",
                title: "使用 Google 账号登录",
                isSystemImage: false,
                iconColor: .gray
            ) {
                // Handle Google login
                print("Google Login tapped")
            }
            
            SocialLoginButton(
                icon: "applelogo",
                title: "使用 Apple 登录",
                isSystemImage: true,
                iconColor: .blue
            ) {
                // Handle Apple login
                print("Apple Login tapped")
            }
        }
        .padding(.bottom, 20)
    }
    
    private var backButton: some View {
        showBackButton ? Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.black)
        } : nil
    }
    
    private var nextButton: some View {
          Button(action: {
              if viewModel.validateAndProceed() {
                  navigationManager.navigate(to: .loginPassword(email: viewModel.inputData.email))
              }
          }) {
              Text("下一步")
                  .font(.system(size: 12, weight: .medium))
                  .padding(.horizontal, 16)
                  .padding(.vertical, 6)
                  .foregroundColor(.white)
                  .background(viewModel.isLoginEnabled ? Color.black : Color.gray)
                  .cornerRadius(25)
          }
          .disabled(!viewModel.isLoginEnabled)
      }
}

// MARK: - Preview
struct LoginInputView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LoginInputView(showBackButton: true)
        }
    }
}
