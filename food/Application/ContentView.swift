import SwiftUI
import FirebaseAuth

struct ContentView: View {
    // MARK: - 依赖注入
    // 通过环境对象注入各种管理器
    @EnvironmentObject private var tabBarManager: TabBarManager      // 标签栏管理器
    @EnvironmentObject private var authManager: AuthManager         // 认证管理器
    @EnvironmentObject private var navigationManager: AppNavigationManager  // 导航管理器
    @EnvironmentObject private var locationManager: LocationManager  // 位置管理器
    
    // 注释掉的初始启动标志
//    @AppStorage("hasCompletedInitialLaunch") private var hasCompletedInitialLaunch = false
    
    // MARK: - 主视图
    var body: some View {
        // 使用 NavigationStack 处理应用导航
        NavigationStack(path: $navigationManager.navigationPath) {
            Group {
                // 根据不同状态显示相应的视图
                if authManager.isLoading {
                    // 加载状态显示加载视图
                    loadingView
                } else if let error = authManager.error {
                    // 出现错误时显示错误视图
                    errorView(error)
                } else if let user = authManager.currentUser {
                    // 用户已登录时的逻辑处理
                    if user.isEmailVerified {
                        // 邮箱已验证
                        if authManager.userProfile != nil {
                            // 用户资料存在，显示主页
                            HomeView()
                                .onAppear {
                                // 设置根视图控制器
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let window = windowScene.windows.first {
                                    let homeView = HomeView()
                                        // 注入环境对象
                                        .environmentObject(tabBarManager)
                                        .environmentObject(navigationManager)
                                        .environmentObject(authManager)
                                        .environmentObject(locationManager)
                                    
                                    let rootViewController = UIHostingController(rootView: homeView)
                                    
                                    window.rootViewController = rootViewController
                                    window.makeKeyAndVisible()
                                }
                            }
                        } else {
                            // 用户资料不存在，显示加载视图
                            loadingView
                        }
                    } else {
                        // 邮箱未验证，显示验证视图
                        VerificationView(email: user.email ?? "")
                    }
                } else {
                    // 用户未登录，显示登录主页
                    HomeLoginView()
                }
            }
            // 设置导航目标视图
            .navigationDestination(for: AppRoute.self) { route in
                viewForRoute(route)
            }
            // 设置模态页面
            .sheet(isPresented: $navigationManager.isPresentingSheet) {
                sheetForRoute(navigationManager.presentedSheet)
            }
        }
    }
    
    // MARK: - 路由处理器
    // 根据路由返回对应的视图
    @ViewBuilder
    private func viewForRoute(_ route: AppRoute) -> some View {
        switch route {
        case .chatDetail(let chatRoom):
            ChatDetailView(chatRoom: chatRoom)            // 聊天详情页
        case .login(let showBackButton):
            LoginInputView(showBackButton: showBackButton)  // 登录输入页
        case .loginPassword(let email):
            LoginPasswordView(emailOrUsername: email)      // 密码登录页
        case .register:
            RegisterView()                                // 注册页
        case .createAccount(let email):
            CreateAccountView(emailOrPhone: email)        // 创建账号页
        case .verification(let email):
            VerificationView(email: email)                // 验证页
        case .passwordChanged:
            PasswordChangedView()                         // 密码修改成功页
        case .forgetPassword:
            ForgetPasswordView()                          // 忘记密码页
        case .profileEditor:
            ProfileEditorView()                           // 个人资料编辑页
        case .settings:
            PersonSettingsView()                          // 个人设置页
        case .passwordChange:
            PasswordChangeView()                          // 修改密码页
        case .postDetail(let post):
            PostDetailView(post: post)                    // 帖子详情页
        default:
            EmptyView()                                   // 默认空视图
        }
    }
    
    // 处理模态页面的路由
    @ViewBuilder
    private func sheetForRoute(_ route: AppRoute?) -> some View {
        if let route = route {
            switch route {
            case .postInput:
                // 发帖输入页
                PostInputView(
                    isPresented: $navigationManager.isPresentingSheet,
                    selectedTab: .constant(navigationManager.selectedTab)
                )
            case .searchFilter:
                // 搜索过滤页
                SearchFilterView(showFilterView: $navigationManager.isPresentingSheet)
            default:
                EmptyView()
            }
        }
    }
    
    // MARK: - 辅助视图
    // 加载中视图
    private var loadingView: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
    }
    
    // 错误视图
    private func errorView(_ error: AuthError) -> some View {
        VStack(spacing: 16) {
            Text("认证错误")
                .font(.headline)
            Text(error.errorDescription ?? "未知错误")
                .font(.subheadline)
                .foregroundColor(.red)
            Button("重试") {
                Task {
                    try? await authManager.validateCurrentSession()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

// MARK: - 预览
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            // 为预览注入必要的环境对象
            .environmentObject(TabBarManager())
            .environmentObject(AuthManager())
            .environmentObject(AppNavigationManager.shared)
            .environmentObject(LocationManager.shared)
    }
}
