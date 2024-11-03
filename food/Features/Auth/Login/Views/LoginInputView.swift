import SwiftUI

// 登录状态管理
final class LoginInputState: ObservableObject {
    @Published var email: String = ""
    @Published var isNextEnabled: Bool = false
    
    func validateEmail() {
        isNextEnabled = !email.isEmpty
    }
}

// 社交登录按钮样式
struct SocialLoginButton: View {
    let icon: String
    let title: String
    let isSystemImage: Bool
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isSystemImage {
                    Image(systemName: icon)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(iconColor)
                } else {
                    Image(icon)
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }
}

struct LoginInputView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var loginState = LoginInputState()
    @State private var navigateToNextStep = false
    
    let showBackButton: Bool
    @EnvironmentObject var tabBarManager: TabBarManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                titleSection
                emailInputSection
                Spacer()
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
        .navigationDestination(isPresented: $navigateToNextStep) {
            LoginPasswordView(emailOrUsername: loginState.email)
                .environmentObject(tabBarManager)
        }
    }
    
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
            text: $loginState.email,
            systemImage: loginState.email.isEmpty ? "" : "checkmark.circle.fill",
            isSecure: false
        )
        .submitLabel(.done)
        .onChange(of: loginState.email) {
            loginState.validateEmail()
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
                print("Google Login tapped")
            }
            
            SocialLoginButton(
                icon: "applelogo",
                title: "使用 Apple 登录",
                isSystemImage: true,
                iconColor: .blue
            ) {
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
            navigateToNextStep = true
        }) {
            Text("下一步")
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .foregroundColor(.white)
                .background(loginState.isNextEnabled ? Color.black : Color.gray)
                .cornerRadius(25)
        }
        .disabled(!loginState.isNextEnabled)
    }
}

struct LoginInputView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LoginInputView(showBackButton: true)
                .environmentObject(TabBarManager())
        }
    }
}
