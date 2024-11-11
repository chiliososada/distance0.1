import SwiftUI
import FirebaseAuth


// ContentView.swift
struct ContentView: View {
    // 使用环境对象而不是创建新的实例
    @EnvironmentObject var tabBarManager: TabBarManager
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var navigationManager: AppNavigationManager
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        NavigationStack(path: $navigationManager.navigationPath) {
            Group {
                if authManager.isLoggedIn {
                    if authManager.isEmailVerified {
                        HomeView()
                            .onAppear {
                                navigationManager.resetNavigation()
                                tabBarManager.resetNavigationState()
                              
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let window = windowScene.windows.first {
                                    // 使用已有的环境对象，而不是创建新的
                                    let homeView = HomeView()
                                        .environmentObject(tabBarManager)
                                        .environmentObject(navigationManager)
                                        .environmentObject(authManager)
                                        .environmentObject(locationManager)
                                    
                                    window.rootViewController = UIHostingController(rootView: homeView)
                                    window.makeKeyAndVisible()
                                }
                            }
                        //                                     .environmentObject(TabBarManager())
                        //                                     .environmentObject(AuthManager())
                        //                                     .environmentObject(AppNavigationManager.shared)
                        //                                     .environmentObject(LocationManager.shared)
                    } else {
                        VerificationView(email: Auth.auth().currentUser?.email)
                    }
                } else {
                    HomeLoginView()
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
                    //                case .foundEmail(let email):
                    //                    FoundEmailView(email: email)
                    //                case .forgetCode(let email):
                    //                    ForgetCodeInputView(email: email)
                    //                case .getNewPassword:
                    //                    GetNewPasswordView()
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
            }
            .task {
                // 在视图加载时检查认证状态
                await authManager.checkAuthState()
                if authManager.isLoggedIn {
                    await authManager.checkEmailVerification()
                }
            }
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
