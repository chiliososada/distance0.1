import SwiftUI

// 底部按钮组件
struct BottomButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.black)
                .cornerRadius(25)
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}

struct PasswordChangedView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var tabBarManager: TabBarManager
    @State private var navigateToLogin = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            contentView
            loginButton
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToLogin) {
            LoginInputView(showBackButton: false)
                .environmentObject(tabBarManager)
        }
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 30) {
                messageSection
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .frame(maxHeight: .infinity)
        }
    }
    
    private var messageSection: some View {
        HStack {
            Text("你的新密码已经修改成功，现在可以登录了。")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 30)
    }
    
    private var loginButton: some View {
        BottomButton(title: "登录") {
            navigateToLogin = true
        }
    }
}

// MARK: - Preview
struct PasswordChangedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PasswordChangedView()
                .environmentObject(TabBarManager())
        }
    }
}
