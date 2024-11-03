//
//  AppNavigationManager.swift
//  food
//
//  Created by toyousoft on 2024/10/31.
//

import SwiftUI

// MARK: - Navigation Route Enums
enum AppRoute: Hashable {
    case login
    case register
    case createAccount(email: String)
    case verification
    case passwordChanged
    case forgetPassword
    case foundEmail(email: String)
    case forgetCode(email: String)
    case getNewPassword
    case chatDetail(chatRoom: ChatRoom)
    case profileEditor
    case settings
    case passwordChange
    case recipeDetail(recipe: RecommendedRecipe)
}

enum TabSelection {
    case home
    case nearby
    case post
    case chat
    case profile
}

// MARK: - Navigation Manager
final class AppNavigationManager: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedTab: TabSelection = .home
    @Published var navigationPath = NavigationPath()
    @Published var presentedSheet: AppRoute?
    @Published var chatNavigationSource: ChatNavigationSource = .normal
    @Published var pendingChatRoom: ChatRoom?
    
    // Navigation source types
    enum ChatNavigationSource {
        case normal
        case fromRecipe
    }
    
    // MARK: - Navigation Methods
    func navigateToRoute(_ route: AppRoute) {
        navigationPath.append(route)
    }
    
    func navigateToTab(_ tab: TabSelection) {
        selectedTab = tab
    }
    
    func presentSheet(_ route: AppRoute) {
        presentedSheet = route
    }
    
    func dismissSheet() {
        presentedSheet = nil
    }
    
    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
    
    func goBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    // MARK: - Specialized Navigation Methods
    func navigateToChat(fromRecipe recipe: RecommendedRecipe) {
        let chatRoom = ChatRoom(
            name: recipe.title,
            lastMessage: "开始新的对话",
            time: formatCurrentTime(),
            avatar: recipe.imageNames.first ?? "",
            isGroupChat: false
        )
        
        chatNavigationSource = .fromRecipe
        pendingChatRoom = chatRoom
        selectedTab = .chat
    }
    
    private func formatCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
    
    func resetNavigation() {
        chatNavigationSource = .normal
        selectedTab = .home
        pendingChatRoom = nil
        navigationPath.removeLast(navigationPath.count)
    }
}

// MARK: - Navigation View Modifier
struct AppNavigationViewModifier: ViewModifier {
    @StateObject private var navigationManager = AppNavigationManager()
    
    func body(content: Content) -> some View {
        NavigationStack(path: $navigationManager.navigationPath) {
            content
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .login:
                        LoginInputView(showBackButton: true)
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
                    case .chatDetail(let chatRoom):
                        ChatDetailView(chatRoom: chatRoom)
                    case .profileEditor:
                        ProfileEditorView()
                    case .settings:
                        PersonSettingsView()
                    case .passwordChange:
                        PasswordChangeView()
                    case .recipeDetail(let recipe):
                        RecipeDetailView(recipe: recipe)
                    }
                }
        }
        .environmentObject(navigationManager)
    }
}

// MARK: - View Extension
extension View {
    func withAppNavigation() -> some View {
        self.modifier(AppNavigationViewModifier())
    }
}
