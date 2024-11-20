import SwiftUI

struct RegisterView: View {
    // MARK: - Properties
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var navigationManager: AppNavigationManager
    init() {
      
        print("RegisterView")
       
    }
    // MARK: - Layout Constants
    private enum Layout {
        static let spacing: CGFloat = 20
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
        VStack(spacing: Layout.spacing) {
            ScrollView {
                VStack(spacing: Layout.spacing) {
                    titleSection
                    emailInputSection
                    dividerSection
                    socialLoginSection
                }
            }
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .alert("提示", isPresented: $viewModel.showAlert) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
        .overlay {
            if viewModel.isLoading {
                loadingView
            }
        }
    }
    
    // MARK: - View Components
    private var titleSection: some View {
        HStack {
            Text("开始注册Distance吧")
                .font(.system(size: Layout.titleSize, weight: .bold))
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.horizontal, Layout.Padding.horizontal)
        .padding(.top, Layout.Padding.top)
    }
    
    private var emailInputSection: some View {
        VStack(spacing: Layout.spacing) {
            TextField("邮件地址", text: $viewModel.emailOrPhone)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .onChange(of: viewModel.emailOrPhone) {
                    viewModel.handleEmailInput()
                }
            
            Button(action: {
                guard viewModel.isValid else { return }
                navigationManager.navigate(to: .createAccount(email: viewModel.emailOrPhone))
            }) {
                Text("继续使用邮箱")
                    .font(.system(size: Layout.buttonTextSize, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(viewModel.isValid ? Color.black : Color.gray)
                    .cornerRadius(Layout.cornerRadius)
            }
            .disabled(!viewModel.isValid)
        }
        .padding(.horizontal, Layout.Padding.horizontal)
    }
    
    private var dividerSection: some View {
        HStack {
            Rectangle()
                .frame(height: Layout.strokeWidth)
                .foregroundColor(.gray.opacity(Layout.dividerOpacity))
            
            Text("或")
                .foregroundColor(.gray)
            
            Rectangle()
                .frame(height: Layout.strokeWidth)
                .foregroundColor(.gray.opacity(Layout.dividerOpacity))
        }
        .padding(.horizontal, Layout.Padding.horizontal)
    }
    
    private var socialLoginSection: some View {
        VStack(spacing: Layout.spacing) {
            Button(action: {
                Task {
                    await viewModel.handleGoogleLogin()
                }
            }) {
                SocialLoginButton(
                    icon: "google",
                    title: "使用 Google 账号注册",
                    isSystemImage: false,
                    iconColor: .gray,
                    action: {}
                )
            }
            .disabled(viewModel.isProcessingGoogle)
            
            Button(action: {
                Task {
                    await viewModel.handleAppleLogin()
                }
            }) {
                SocialLoginButton(
                    icon: "applelogo",
                    title: "使用 Apple 账号注册",
                    isSystemImage: true,
                    iconColor: .black,
                    action: {}
                )
            }
            .disabled(viewModel.isProcessingApple)
        }
        .padding(.horizontal, Layout.Padding.horizontal)
    }
    
    private var backButton: some View {
        Button(action: { presentationMode.wrappedValue.dismiss() }) {
            Image(systemName: "arrow.left")
                .font(.system(size: Layout.buttonTextSize, weight: .medium))
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
}

// MARK: - Preview
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RegisterView()
                .environmentObject(AppNavigationManager.shared)
        }
    }
}
