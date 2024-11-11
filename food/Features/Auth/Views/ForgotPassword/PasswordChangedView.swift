import SwiftUI

struct PasswordChangedView: View {
    @EnvironmentObject var navigationManager: AppNavigationManager
    @StateObject private var viewModel = PasswordChangedViewModel()
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
            
            Text("密码修改成功")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("您的密码已经成功更新，请使用新密码登录")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            Spacer()
            
            Button {
                navigationManager.navigate(to: .login(showBackButton: true))
            } label: {
                Text("返回登录")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct PasswordChangedView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordChangedView()
            .environmentObject(AppNavigationManager.shared)
    }
}
