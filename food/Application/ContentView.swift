import SwiftUI



// ContentView.swift
struct ContentView: View {
    @StateObject private var tabBarManager = TabBarManager()
    @StateObject private var authManager = AuthManager()
    @StateObject private var navigationManager = AppNavigationManager.shared
    
    var body: some View {
        NavigationStack(path: $navigationManager.navigationPath) {
            Group {
                if authManager.isLoggedIn {
                    HomeView()
                        .environmentObject(tabBarManager)
                        .environmentObject(authManager)
                } else {
                    HomeLoginView()
                        .environmentObject(tabBarManager)
                        .environmentObject(authManager)
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .chatDetail(let chatRoom):
                    ChatDetailView(chatRoom: chatRoom)
                case .login(let showBackButton):
                    LoginInputView(showBackButton: showBackButton)
                case .loginPassword(let email):
                    LoginPasswordView(emailOrUsername: email)
                case .register:
                    RegisterView()
                case .createAccount(let email):
                    CreateAccountView(emailOrPhone: email)
                case .verification:
                    VerificationView()
                case .passwordChanged:
                    PasswordChangedView()
                case .forgetPassword:
                    ForgetPasswordAccountView()
                case .foundEmail(let email):
                    FoundEmailView(email: email)
                case .forgetCode(let email):
                    ForgetCodeInputView(email: email)
                case .getNewPassword:
                    GetNewPasswordView()
                case .profileEditor:
                    ProfileEditorView()
                case .settings:
                    PersonSettingsView()
                case .passwordChange:
                    PasswordChangeView()
                case .postDetail(let LocationPost):
                    PostDetailView(post: LocationPost)
                default:
                    EmptyView()
                }
            }
            .sheet(isPresented: $navigationManager.isPresentingSheet) {
                if let route = navigationManager.presentedSheet {
                    switch route {
                    case .postInput:
                        PostInputView(
                            isPresented: $navigationManager.isPresentingSheet,
                             selectedTab: .constant(navigationManager.selectedTab)
                        )
                    case .searchFilter:
                        SearchFilterView(showFilterView: $navigationManager.isPresentingSheet)
                    case .imageGallery:
                        EmptyView() // 实现图片画廊视图
                    case .locationPicker:
                        EmptyView() // 实现位置选择器视图
                    default:
                        EmptyView()
                    }
                }
            }
        }
        .environmentObject(navigationManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TabBarManager())
    }
}

// 在登录成功的地方调用：
// authManager.signIn()

// 在需要登出的地方调用：
// authManager.signOut()
