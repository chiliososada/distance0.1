import SwiftUI
import FirebaseAuth

struct ContentView: View {
    // MARK: - Environment Objects
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var navigationManager: AppNavigationManager
    
    private let viewId = UUID().uuidString
    
    init() {
        print("ContentView initialized with id: \(viewId)")
    }
    
    // MARK: - Main View
    var body: some View {
        NavigationStack(path: $navigationManager.navigationPath) {
            Group {
                if  !authManager.isInitialized || authManager.isLoading {
                    loadingView
                } else if let error = authManager.error {
                    errorView(error)
                } else if let user = authManager.currentUser {
                    if user.isEmailVerified {
                        if authManager.userProfile != nil {
                            HomeView()
                        } else {
                            loadingView
                        }
                    } else {
                        VerificationView(email: user.email ?? "")
                    }
                } else {
                    HomeLoginView()
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                viewForRoute(route)
            }
            .sheet(isPresented: $navigationManager.isPresentingSheet) {
                sheetForRoute(navigationManager.presentedSheet)
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
        case .home:
            HomeView()
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

// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(GlobalManagers.preview.authManager)
            .environmentObject(GlobalManagers.preview.navigationManager)
            .environmentObject(GlobalManagers.preview.locationManager)
    }
}

