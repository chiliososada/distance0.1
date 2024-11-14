import SwiftUI
import FirebaseAuth

struct ContentView: View {
    // MARK: - Dependencies
    @EnvironmentObject var tabBarManager: TabBarManager
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var navigationManager: AppNavigationManager
    @EnvironmentObject var locationManager: LocationManager
    private let sessionManager = SessionManager.shared // 添加 SessionManager
    
    // MARK: - View States
    @State private var isFirstLaunch = true  // 用于追踪当前会话的首次加载
    @State private var isCheckingAuth = true  // 认证检查状态
    @AppStorage("hasCompletedInitialLaunch") private var hasCompletedInitialLaunch = false
    @Environment(\.scenePhase) private var scenePhase
    
    // MARK: - Body
    var body: some View {
        NavigationStack(path: $navigationManager.navigationPath) {
            Group {
                if isCheckingAuth {
                    loadingView
                } else {
                    switch authManager.state {
                    case .authenticated:
                        HomeView()
                        
                    case .emailUnverified(let email):
                        VerificationView(email: email)
                        
                    case .unauthenticated, .initial:
                        HomeLoginView()
                        
                    case .error(let error):
                        errorView(error)
                        
                    case .loading:
                        loadingView
                    }
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                viewForRoute(route)
            }
            .sheet(isPresented: $navigationManager.isPresentingSheet) {
                sheetForRoute(navigationManager.presentedSheet)
            }
            .task {
                guard isFirstLaunch else { return }
                isFirstLaunch = false
                
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
            .onChange(of: scenePhase) { oldPhase, newPhase in
                handleScenePhaseChange(from: oldPhase, to: newPhase)
            }
        }
    }
    
    // MARK: - Route Handlers
    @ViewBuilder
    private func viewForRoute(_ route: AppRoute) -> some View {
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
        case .postDetail(let post):
            PostDetailView(post: post)
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func sheetForRoute(_ route: AppRoute?) -> some View {
        if let route = route {
            switch route {
            case .postInput:
                PostInputView(
                    isPresented: $navigationManager.isPresentingSheet,
                    selectedTab: .constant(navigationManager.selectedTab)
                )
            case .searchFilter:
                SearchFilterView(showFilterView: $navigationManager.isPresentingSheet)
            default:
                EmptyView()
            }
        }
    }
    
    // MARK: - Helper Views
    private var loadingView: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
    }
    
    private func errorView(_ error: AuthError) -> some View {
        VStack {
            Text("认证错误")
                .font(.headline)
            Text(error.errorDescription ?? "未知错误")
                .font(.subheadline)
                .foregroundColor(.red)
            Button("重试") {
                Task {
                    await verifyAuthState()
                }
            }
            .padding()
        }
    }
    
    // MARK: - Auth Methods
    /// 完整的初始化流程，只在首次启动时执行
    private func performInitialSetup() async {
        print("Performing initial setup")
        
        if case .authenticated(let profile) = authManager.state {
            print("User is authenticated, setting up session")
            await sessionManager.updateSession(user: profile)
            
            print("Setting up HomeView")
            await MainActor.run {
                setupHomeView()
            }
        } else {
            print("User is not authenticated")
        }
    }

    
    /// 判断是否需要刷新认证状态
    private func shouldRefreshAuth() async -> Bool {
        if let lastVerification = UserDefaults.standard.object(forKey: "lastAuthVerification") as? Date {
            let timeInterval = Date().timeIntervalSince(lastVerification)
            return timeInterval > 1800 // 30分钟
        }
        return true
    }
    
    /// 验证认证状态
    private func verifyAuthState() async {
        print("Verifying auth state")
        
        // 先检查是否有保存的用户配置
        if let encoded = UserDefaults.standard.data(forKey: AppConstants.UserDefaultsKeys.userProfile),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: encoded) {
            print("Found saved user profile, updating session")
            
            // 更新会话
            await sessionManager.updateSession(user: profile)
            
            print("User is verified, updating view")
            await MainActor.run {
                setupHomeView()
            }
        } else {
            switch authManager.state {
            case .authenticated(let profile):
                print("Found authenticated user, updating session")
                await sessionManager.updateSession(user: profile)
                
                print("User is verified, updating view")
                await MainActor.run {
                    setupHomeView()
                }
                
            case .emailUnverified(let email):
                print("User email not verified: \(email)")
                
            case .unauthenticated, .initial:
                print("User not authenticated")
                
            case .error(let error):
                print("Auth error: \(error.localizedDescription)")
                
            case .loading:
                print("Auth state is loading")
            }
        }
        
        // 记录验证时间
        UserDefaults.standard.set(Date(), forKey: "lastAuthVerification")
    }
    
    // MARK: - UI Setup
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
    
    // MARK: - Scene Phase Handling
    private func handleScenePhaseChange(from oldPhase: ScenePhase, to newPhase: ScenePhase) {
        if newPhase == .active {
            // 只在特定条件下验证认证状态
            if case .authenticated = authManager.state {
                Task {
                    if await shouldRefreshAuth() {
                        print("Refreshing auth state after background")
                        await verifyAuthState()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TabBarManager())
            .environmentObject(AuthManager())
            .environmentObject(AppNavigationManager.shared)
            .environmentObject(LocationManager.shared)
    }
}
