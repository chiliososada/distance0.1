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
    case loginPassword(email: String)
    case createAccount(email: String)
    case passwordChanged
    case forgetPassword
    
    // Main Flow
    case chatDetail(chatRoom: ChatRoom)
    case profileEditor
    case settings
    case privacyPolicy
    case about
    case passwordChange
    case postDetail(post: LocationPost)
    case home
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
    @Published var navigationPath = NavigationPath() {
        didSet {
            print("Navigation path changed: \(navigationPath)")
        }
    }
    
    @Published var selectedTab: TabRoute = .home {
        didSet {
            print("Selected tab changed to: \(selectedTab)")
        }
    }
    
    @Published var presentedSheet: AppRoute? {
        didSet {
            print("Presented sheet changed to: \(String(describing: presentedSheet))")
        }
    }
    
    @Published var isPresentingSheet = false {
        didSet {
            print("isPresentingSheet changed to: \(isPresentingSheet)")
        }
    }
    
    @Published var chatNavigationSource: ChatNavigationSource = .normal {
        didSet {
            print("Chat navigation source changed")
        }
    }
    
    @Published var pendingChatRoom: ChatRoom? {
        didSet {
            print("Pending chat room \(pendingChatRoom != nil ? "set" : "cleared")")
        }
    }
    
    @Published var isNavigationBarHidden = false {
        didSet {
            print("Navigation bar hidden state changed to: \(isNavigationBarHidden)")
        }
    }
    
    @Published var isTabBarHidden = false {
        didSet {
            print("Tab bar hidden state changed to: \(isTabBarHidden)")
        }
    }
    
    // MARK: - Initialization
    init() {
            print("AppNavigationManager initialized")
        }
    
    // MARK: - Core Navigation Methods
    func navigate(to route: AppRoute) {
        print("Navigating to route: \(route)")
        navigationPath.append(route)
    }
    
    func present(_ route: AppRoute) {
        print("Presenting sheet: \(route)")
        presentedSheet = route
        isPresentingSheet = true
    }
    
    func dismiss() {
        print("Dismissing sheet")
        presentedSheet = nil
        isPresentingSheet = false
    }
    
    func popToRoot() {
        print("Popping to root")
        navigationPath = NavigationPath()
    }
    
    func goBack() {
        print("Going back")
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    @MainActor
    func navigateToHome() {
        // 如果已经在主页且tab是home，直接返回
        if selectedTab == .home && navigationPath.count <= 1 {
            return
        }
        
        // 否则才执行导航
        navigationPath = NavigationPath()
        selectedTab = .home
    }
    
    
    func navigateToTab(_ tab: TabRoute) {
        print("Navigating to tab: \(tab)")
        selectedTab = tab
    }
    
    func switchTab(to tab: TabRoute) {
        print("Switching to tab: \(tab)")
        selectedTab = tab
    }
    
    func clearNavigationPath() {
        print("Clearing navigation path")
        navigationPath = NavigationPath()
    }
    
    func resetNavigation() {
        print("Resetting navigation state")
        navigationPath = NavigationPath()
        chatNavigationSource = .normal
        selectedTab = .home
        isNavigationBarHidden = false
        isTabBarHidden = false
        pendingChatRoom = nil
        isPresentingSheet = false
        presentedSheet = nil
    }
    
    // MARK: - Cleanup
    deinit {
        print("AppNavigationManager deinitialized")
    }
}

// MARK: - Preview Helper
#if DEBUG
extension AppNavigationManager {
    static var preview: AppNavigationManager {
        return AppNavigationManager.shared
    }
}
#endif
