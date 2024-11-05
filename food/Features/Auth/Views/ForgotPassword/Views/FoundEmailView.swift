import SwiftUI

struct FoundEmailView: View {
    @Environment(\.presentationMode) var presentationMode
    let email: String  // 改为 let 常量，因为邮箱不会改变
    @EnvironmentObject var tabBarManager: TabBarManager
    @State private var navigateToCodeInput = false
    @EnvironmentObject var navigationManager: AppNavigationManager
   
    private var titleText: some View {
        Text("请点击下一步，我们将会给你的邮箱发送一个代码。")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.black)
    }
    
    private var emailField: some View {
        InputField(
            placeholder: "电子邮箱",
            text: .constant(email),
            systemImage: "checkmark.circle.fill",
            isSecure: false
        )
        .disabled(true)
        .submitLabel(.done)
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.black)
        }
    }
    
    private var nextButton: some View {
//        Button(action: {
//            navigateToCodeInput = true
//        })
        Button(action: handleNextStep){
            Text("下一步")
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .foregroundColor(.white)
                .background(Color.black)
                .cornerRadius(25)
        }
        .disabled(email.isEmpty)
    }
    private func handleNextStep() {
       
        navigationManager.navigate(to: .forgetCode(email: email))
        
    }
    var body: some View {
        let content = ScrollView {
            VStack(spacing: 30) {
                HStack {
                    titleText
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 30)
                
                emailField
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .background(Color.white)
        }
        
        ZStack {
            content
        }
        .ignoresSafeArea(.keyboard)
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton, trailing: nextButton)
//        .navigationDestination(isPresented: $navigateToCodeInput) {
//            ForgetCodeInputView(email: email)
//                .environmentObject(tabBarManager)
//        }
    }
}

// 预览
struct FoundEmailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FoundEmailView(email: "example@example.com")
                .environmentObject(TabBarManager())
        }
    }
}
