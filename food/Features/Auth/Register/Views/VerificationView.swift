import SwiftUI

// 验证码管理状态
final class VerificationState: ObservableObject {
    @Published var code: [String] = Array(repeating: "", count: 6)
    
    var isComplete: Bool {
        code.joined().count == 6
    }
    
    func shouldAdvanceToNextField(at index: Int) -> Bool {
        code[index].count == 1 && index < 5
    }
}

struct VerificationView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var verificationState = VerificationState()
    @FocusState private var focusedField: Int?
    @EnvironmentObject var tabBarManager: TabBarManager
    
    let emailPlaceholder: String = "chiliososada@gmail.com"
    
    var body: some View {
        VStack(spacing: 30) {
            headerSection
            codeInputSection
            Spacer()
            submitButton
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("我们向你发送了一个代码")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            
            Text("在下面输入以验证\(emailPlaceholder)")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 30)
    }
    
    private var codeInputSection: some View {
        HStack(spacing: 10) {
            ForEach(0..<6, id: \.self) { index in
                CodeInputBox(text: $verificationState.code[index])
                    .focused($focusedField, equals: index)
                    .onChange(of: verificationState.code[index]) {
                        if verificationState.shouldAdvanceToNextField(at: index) {
                            focusedField = index + 1
                        }
                    }
            }
        }
    }
    
    private var submitButton: some View {
        Button(action: goToHomeView) {
            Text("完成")
                .font(.system(size: 18, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(verificationState.isComplete ? Color.black : Color.gray)
                .cornerRadius(25)
        }
        .disabled(!verificationState.isComplete)
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    private var backButton: some View {
        Button(action: { presentationMode.wrappedValue.dismiss() }) {
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.black)
        }
    }
    
    private func goToHomeView() {
        guard verificationState.isComplete,
              let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        window.rootViewController = UIHostingController(
            rootView: HomeView().environmentObject(tabBarManager)
        )
        window.makeKeyAndVisible()
    }
}

// MARK: - Previews
struct VerificationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            VerificationView()
                .environmentObject(TabBarManager())
        }
    }
}
