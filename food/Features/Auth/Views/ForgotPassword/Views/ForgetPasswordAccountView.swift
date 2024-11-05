import SwiftUI


struct ForgetPasswordAccountView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = ForgetPasswordViewModel()
    @State private var navigateToFoundEmail = false
    @EnvironmentObject var navigationManager: AppNavigationManager
    @EnvironmentObject var tabBarManager: TabBarManager
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    titleSection
                    emailInputSection
                    if viewModel.showError {
                        errorMessage
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton, trailing: nextButton)
//        .navigationDestination(isPresented: $navigateToFoundEmail) {
//            FoundEmailView(email: viewModel.email)
//                .environmentObject(tabBarManager)
//        }
    }
    
    // MARK: - UI Components
    
    private var titleSection: some View {
        Text("查找你的账号，请先输入你的电子邮箱")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.black)
    }
    
    private var emailInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            InputField(
                placeholder: "电子邮箱",
                text: $viewModel.email,
                systemImage: viewModel.isEmailValid ? "checkmark.circle.fill" : "",
                isSecure: false
            )
            .onChange(of: viewModel.email) {
                viewModel.validateEmail()
            }
            .submitLabel(.done)
            .autocapitalization(.none)
            .keyboardType(.emailAddress)
        }
    }
    
    private var errorMessage: some View {
        Text(viewModel.errorMessage)
            .foregroundColor(.red)
            .font(.footnote)
            .transition(.opacity)
    }
    
    private var backButton: some View {
        Button(action: { presentationMode.wrappedValue.dismiss() }) {
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.black)
        }
    }
    
    private var nextButton: some View {
//        Button(action: {
//            if viewModel.isEmailValid {
//                navigateToFoundEmail = true
//            }
//        })
        Button(action: handleNextStep){
            Text("下一步")
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .foregroundColor(.white)
                .background(viewModel.isEmailValid ? Color.black : Color.gray.opacity(0.5))
                .cornerRadius(25)
        }
        .disabled(!viewModel.isEmailValid)
    }
    private func handleNextStep() {
                    if viewModel.isEmailValid {
                        // 使用 navigationManager 导航到找到邮箱页面
                        navigationManager.navigate(to: .foundEmail(email: viewModel.email))
                    }
               
            
        }
}

// MARK: - Preview
struct ForgetPasswordAccountView_Previews: PreviewProvider {
    static var previews: some View {
        ForgetPasswordAccountView()
            .environmentObject(TabBarManager())
    }
}
