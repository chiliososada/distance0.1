import SwiftUI

// MARK: - Constants
private enum Layout {
    static let spacing: CGFloat = 20
    static let buttonHeight: CGFloat = 25
    static let iconSize: CGFloat = 20
    static let cornerRadius: CGFloat = 25
    static let titleSize: CGFloat = 28
    static let buttonTextSize: CGFloat = 20
    static let dividerOpacity: CGFloat = 0.5
    static let strokeWidth: CGFloat = 1
    
    enum Padding {
        static let horizontal: CGFloat = 16
        static let top: CGFloat = 30
        static let bottom: CGFloat = 40
    }
}

// MARK: - View Model
final class RegisterViewModel: ObservableObject {
    @Published var emailOrPhone = ""
    @Published var navigateToCreateAccount = false
    @Published var navigateToForgetPassword = false
    
    func handleGoogleLogin() {
        print("Google Login tapped")
        // 实现 Google 登录逻辑
    }
    
    func handleAppleLogin() {
        print("Apple Login tapped")
        // 实现 Apple 登录逻辑
    }
}

// MARK: - Main View
struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var tabBarManager: TabBarManager
    @StateObject private var viewModel = RegisterViewModel()
    
    var body: some View {
        VStack(spacing: Layout.spacing) {
            ScrollView {
                VStack(spacing: Layout.spacing) {
                    TitleSection()
                    SocialLoginSection(viewModel: viewModel)
                    DividerSection()
                    EmailInputSection(emailOrPhone: $viewModel.emailOrPhone)
                    NavigationSection(viewModel: viewModel)
                }
            }
        }
        .navigationStyle(presentationMode: presentationMode)
        .navigationDestinations(viewModel: viewModel, tabBarManager: tabBarManager)
        .background(Color.white)
    }
}

// MARK: - Supporting Views
private struct TitleSection: View {
    var body: some View {
        HStack {
            Text("开始注册Distance吧")
                .font(.system(size: Layout.titleSize, weight: .bold))
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.horizontal, Layout.Padding.horizontal)
        .padding(.top, Layout.Padding.top)
        .padding(.bottom, Layout.Padding.bottom)
    }
}

private struct SocialLoginSection: View {
    @ObservedObject var viewModel: RegisterViewModel
    
    var body: some View {
        VStack(spacing: Layout.spacing) {
            SocialButton(
                action: viewModel.handleGoogleLogin,
                imageName: "google",
                text: "使用 Google 账号登录"
            )
            
            SocialButton(
                action: viewModel.handleAppleLogin,
                imageName: "applelogo",
                text: "使用 Apple 登录",
                isSystemImage: true
            )
        }
        .padding(.horizontal, Layout.Padding.horizontal)
    }
}

private struct SocialButton: View {
    let action: () -> Void
    let imageName: String
    let text: String
    var isSystemImage: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                
                if isSystemImage {
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Layout.iconSize, height: Layout.iconSize)
                        .foregroundColor(.blue)
                } else {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Layout.iconSize, height: Layout.iconSize)
                        .foregroundColor(.gray)
                }
                
                Text(text)
                    .font(.system(size: Layout.buttonTextSize))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(Layout.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Layout.cornerRadius)
                    .stroke(Color.gray.opacity(0.3), lineWidth: Layout.strokeWidth)
            )
        }
    }
}

private struct DividerSection: View {
    var body: some View {
        HStack {
            Rectangle()
                .frame(height: Layout.strokeWidth)
                .foregroundColor(.gray.opacity(Layout.dividerOpacity))
            
            Text("或")
                .font(.system(size: Layout.buttonTextSize))
                .foregroundColor(.gray)
            
            Rectangle()
                .frame(height: Layout.strokeWidth)
                .foregroundColor(.gray.opacity(Layout.dividerOpacity))
        }
        .padding(.horizontal, Layout.Padding.horizontal)
    }
}

private struct EmailInputSection: View {
    @Binding var emailOrPhone: String
    
    var body: some View {
        TextField("邮件地址", text: $emailOrPhone)
            .textFieldStyle(CustomTextFieldStyle())
            .padding(.horizontal, Layout.Padding.horizontal)
    }
}

private struct NavigationSection: View {
    @ObservedObject var viewModel: RegisterViewModel
    
    var body: some View {
        VStack(spacing: Layout.spacing) {
            NextButton(action: { viewModel.navigateToCreateAccount = true })
            
            Button(action: { viewModel.navigateToForgetPassword = true }) {
                Text("忘记密码?")
                    .font(.system(size: Layout.buttonTextSize))
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, Layout.Padding.horizontal)
    }
}

private struct NextButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("下一步")
                .font(.system(size: Layout.buttonTextSize, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.black)
                .cornerRadius(Layout.cornerRadius)
        }
    }
}

// MARK: - Custom Styles
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: Layout.strokeWidth)
            )
    }
}

// MARK: - View Extensions
private extension View {
    func navigationStyle(presentationMode: Binding<PresentationMode>) -> some View {
        self.navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: Layout.buttonTextSize, weight: .medium))
                        .foregroundColor(.black)
                    
                  
                }
            )
    }
    
    func navigationDestinations(viewModel: RegisterViewModel, tabBarManager: TabBarManager) -> some View {
        self.navigationDestination(
            isPresented: Binding(
                get: { viewModel.navigateToCreateAccount },
                set: { viewModel.navigateToCreateAccount = $0 }
            )
        ) {
            CreateAccountView(emailOrPhone: viewModel.emailOrPhone)
        }
        .navigationDestination(
            isPresented: Binding(
                get: { viewModel.navigateToForgetPassword },
                set: { viewModel.navigateToForgetPassword = $0 }
            )
        ) {
            ForgetPasswordAccountView()
                .environmentObject(tabBarManager)
        }
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
