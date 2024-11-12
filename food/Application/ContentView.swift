import SwiftUI
import FirebaseAuth


// ContentView.swift
struct ContentView: View {
    // 使用环境对象而不是创建新的实例
    @EnvironmentObject var tabBarManager: TabBarManager
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var navigationManager: AppNavigationManager
    @EnvironmentObject var locationManager: LocationManager
    @State private var isFirstLaunch = true  // 用于追踪当前会话的首次加载
    @State private var isCheckingAuth = true  // 添加加载状态
   @AppStorage("hasCompletedInitialLaunch") private var hasCompletedInitialLaunch = false
    var body: some View {
        NavigationStack(path: $navigationManager.navigationPath) {
            Group {
                if isCheckingAuth {
                // 显示加载视图
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                } else {
                    if authManager.isLoggedIn {
                        if authManager.isEmailVerified {
                            HomeView()
                        } else {
                            VerificationView(email: Auth.auth().currentUser?.email)
                        }
                    } else {
                        HomeLoginView()
                    }
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
                case .verification(let email):
                    VerificationView(email: email)
                case .passwordChanged:
                    PasswordChangedView()
                case .forgetPassword:
                    ForgetPasswordView()
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
                        EmptyView()
                    case .locationPicker:
                        EmptyView()
                    default:
                        EmptyView()
                    }
                }
            } .task {
                // 只在当前会话的首次启动时执行一次
                guard isFirstLaunch else { return }
                isFirstLaunch = false
                // 开始检查认证状态
                 isCheckingAuth = true
                if !hasCompletedInitialLaunch {
                    print("First time app launch, performing full setup")
                    await performInitialSetup()
                    hasCompletedInitialLaunch = true
                } else {
                    print("Checking auth state on subsequent launch")
                    await verifyAuthState()
                }
                isCheckingAuth = false
            }
        }
    }
    // 完整的初始化流程，只在首次启动时执行
        private func performInitialSetup() async {
            print("Performing initial setup")
            await authManager.checkAuthState()
            
            if authManager.isLoggedIn {
                print("User is logged in, checking email verification")
                await authManager.checkEmailVerification()
                
                if authManager.isLoggedIn && authManager.isEmailVerified {
                    print("User is verified, setting up HomeView")
                    await MainActor.run {
                        setupHomeView()
                    }
                }
            }
        }
        
        // 简单的认证状态验证，用于后续启动
        private func verifyAuthState() async {
            print("Verifying auth state")
            await authManager.checkAuthState()
            
            if authManager.isLoggedIn && authManager.isEmailVerified {
                print("User is verified, updating view")
                await MainActor.run {
                    setupHomeView()
                }
            }
        }
        
        private func setupHomeView() {
            print("Setting up HomeView")
            navigationManager.resetNavigation()
            tabBarManager.resetNavigationState()
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let homeView = HomeView()
                    .environmentObject(tabBarManager)
                    .environmentObject(navigationManager)
                    .environmentObject(authManager)
                    .environmentObject(locationManager)
                
                window.rootViewController = UIHostingController(rootView: homeView)
                window.makeKeyAndVisible()
            }
        }
}

// MARK: - Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TabBarManager())
            .environmentObject(AuthManager())
            .environmentObject(AppNavigationManager.shared)
            .environmentObject(LocationManager.shared)
    }
}
