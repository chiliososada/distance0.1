//
//  AppNavigationManager.swift
//  food
//
//  Created by toyousoft on 2024/10/31.
//

import SwiftUI

// MARK: - Route Definitions
enum AppRoute: Hashable {
    // Auth Flow
    case login(showBackButton: Bool)
    case register
    case loginPassword(email: String)  // 添加登录密码页面路由
    case createAccount(email: String)
   // case verification
    case passwordChanged
    case forgetPassword
    
    // Main Flow
    case chatDetail(chatRoom: ChatRoom)
    case profileEditor
    case settings
    case passwordChange
    case postDetail(post: LocationPost)
    
    // Sheet Presentations
    case postInput
    case searchFilter
    case imageGallery([UIImage])
    case locationPicker
    case verification(email: String? = nil)
}

enum TabRoute: Int {
    case home = 0
    case nearby
    case post
    case chat
    case profile
}

final class AppNavigationManager: ObservableObject {
    // MARK: - Nested Types
    enum ChatNavigationSource: Equatable {
        case normal
        case fromRecipe(RecipeInfo)
        
        struct RecipeInfo: Equatable {
            let title: String
            let imageUrl: String
            let participantsCount: Int
        }
    }
    
    // MARK: - Singleton Instance
    static let shared: AppNavigationManager = .init()
    
    // MARK: - Published Properties
    @Published var navigationPath = NavigationPath()
    @Published var selectedTab: TabRoute = .home
    @Published var presentedSheet: AppRoute?
    @Published var isPresentingSheet = false
    @Published var chatNavigationSource: ChatNavigationSource = .normal
    @Published var pendingChatRoom: ChatRoom?
    @Published var isNavigationBarHidden = false
    @Published var isTabBarHidden = false
    
    private init() {}
    
    // MARK: - Core Navigation Methods
    func navigate(to route: AppRoute) {
        print("Navigating to route: \(route)")
        navigationPath.append(route)
    }
    
    func present(_ route: AppRoute) {
        presentedSheet = route
        isPresentingSheet = true
    }
    
    func dismiss() {
        presentedSheet = nil
        isPresentingSheet = false
    }
    
    func popToRoot() {
        navigationPath = NavigationPath()
    }
    
    func goBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    func navigateToTab(_ tab: TabRoute) {
        selectedTab = tab
    }
    
    func switchTab(to tab: TabRoute) {
        selectedTab = tab
    }
    
    func clearNavigationPath() {
        navigationPath = NavigationPath()
    }
    
    func resetNavigation() {
        print("Resetting navigation state")
        navigationPath = NavigationPath()
        chatNavigationSource = ChatNavigationSource.normal  // 明确指定类型
        selectedTab = .home
        isNavigationBarHidden = false
        pendingChatRoom = nil
        isPresentingSheet = false
        presentedSheet = nil
    }
}
