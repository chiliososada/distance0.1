import SwiftUI

struct RegisterView: View {
    // MARK: - Properties
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var tabBarManager: TabBarManager
    
    // MARK: - Layout Constants
    private enum Constants {
        static let spacing: CGFloat = 20
        static let buttonHeight: CGFloat = 25
        static let iconSize: CGFloat = 20
        static let cornerRadius: CGFloat = 25
        static let titleSize: CGFloat = 28
        static let buttonTextSize: CGFloat = 20
        static let dividerOpacity: CGFloat = 0.5
        static let strokeWidth: CGFloat = 1
        
        struct Padding {
            static let horizontal: CGFloat = 16
            static let top: CGFloat = 30
            static let bottom: CGFloat = 40
        }
    }
    
    // MARK: - Body
    var body: some View {
            // 修改这里的视图结构
           
                VStack(spacing: Constants.spacing) {
                    ScrollView {
                        VStack(spacing: Constants.spacing) {
                            titleSection
                            socialLoginSection
                            dividerSection
                            emailInputSection
                            navigationSection
                        }
                    }
                }
                .background(Color.white)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(
                    leading: backButton
                )
                .navigationDestination(
                    isPresented: $viewModel.navigateToCreateAccount
                ) {
                    CreateAccountView(emailOrPhone: viewModel.emailOrPhone)
                }
                .navigationDestination(
                    isPresented: $viewModel.navigateToForgetPassword
                ) {
                    ForgetPasswordAccountView()
                        .environmentObject(tabBarManager)
                }
                .alert("提示", isPresented: $viewModel.showAlert) {
                    Button("确定", role: .cancel) {}
                } message: {
                    Text(viewModel.alertMessage)
                }
            
        }
    private var backButton: some View {
          Button(action: {
              presentationMode.wrappedValue.dismiss()
          }) {
              Image(systemName: "arrow.left")
                  .font(.system(size: Constants.buttonTextSize, weight: .medium))
                  .foregroundColor(.black)
          }
      }
    
    // MARK: - View Components
    private var titleSection: some View {
        HStack {
            Text("开始注册Distance吧")
                .font(.system(size: Constants.titleSize, weight: .bold))
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.horizontal, Constants.Padding.horizontal)
        .padding(.top, Constants.Padding.top)
        .padding(.bottom, Constants.Padding.bottom)
    }
    
    private var socialLoginSection: some View {
        VStack(spacing: Constants.spacing) {
            SocialLoginButton(
                icon: "google",
                title: "使用 Google 账号登录",
                isSystemImage: false,
                iconColor: .gray
            ) {
                viewModel.handleGoogleLogin()
            }
            .disabled(viewModel.isProcessingGoogle)
            
            SocialLoginButton(
                icon: "applelogo",
                title: "使用 Apple 登录",
                isSystemImage: true,
                iconColor: .blue
            ) {
                viewModel.handleAppleLogin()
            }
            .disabled(viewModel.isProcessingApple)
        }
        .padding(.horizontal, Constants.Padding.horizontal)
    }
    
    private var dividerSection: some View {
        HStack {
            Rectangle()
                .frame(height: Constants.strokeWidth)
                .foregroundColor(.gray.opacity(Constants.dividerOpacity))
            
            Text("或")
                .font(.system(size: Constants.buttonTextSize))
                .foregroundColor(.gray)
            
            Rectangle()
                .frame(height: Constants.strokeWidth)
                .foregroundColor(.gray.opacity(Constants.dividerOpacity))
        }
        .padding(.horizontal, Constants.Padding.horizontal)
    }
    
    private var emailInputSection: some View {
        TextField("邮件地址", text: $viewModel.emailOrPhone)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .keyboardType(.emailAddress)
            .onChange(of: viewModel.emailOrPhone) {
                viewModel.handleEmailInput()
            }
            .padding(.horizontal, Constants.Padding.horizontal)
    }
    
    private var navigationSection: some View {
        VStack(spacing: Constants.spacing) {
            Button(action: { viewModel.navigateToCreateAccount = true }) {
                Text("下一步")
                    .font(.system(size: Constants.buttonTextSize, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(viewModel.isValid ? Color.black : Color.gray)
                    .cornerRadius(Constants.cornerRadius)
            }
            .disabled(!viewModel.isValid)
            
            Button(action: { viewModel.navigateToForgetPassword = true }) {
                Text("忘记密码?")
                    .font(.system(size: Constants.buttonTextSize))
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, Constants.Padding.horizontal)
    }
}



// MARK: - Preview
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RegisterView()
                .environmentObject(TabBarManager())
        }
    }
}
