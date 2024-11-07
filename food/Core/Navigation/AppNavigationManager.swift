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
    case verification
    case passwordChanged
    case forgetPassword
    case foundEmail(email: String)
    case forgetCode(email: String)
    case getNewPassword
    
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
}

enum TabRoute: Int {
    case home = 0
    case nearby
    case post
    case chat
    case profile
}

// MARK: - Navigation State
final class AppNavigationManager: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedTab: TabRoute = .home
    @Published var navigationPath = NavigationPath()
    @Published var presentedSheet: AppRoute?
    @Published var isPresentingSheet = false
    @Published var chatNavigationSource: ChatNavigationSource = .normal
    @Published var pendingChatRoom: ChatRoom?
    @Published var isNavigationBarHidden = false
    @Published var isTabBarHidden = false
    
    // MARK: - Navigation Source Types
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
    static let shared = AppNavigationManager()
    private init() {}
    
    // MARK: - Core Navigation Methods
    func navigate(to route: AppRoute) {
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
        navigationPath.removeLast(navigationPath.count)
    }
    
    func goBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    func navigateToTab(_ tab: TabRoute) {
            selectedTab = tab
        }
    // MARK: - Tab Navigation
    func switchTab(to tab: TabRoute) {
        selectedTab = tab
    }

    
    func clearNavigationPath() {
            // 移除导航路径中的所有项目
            while !navigationPath.isEmpty {
                navigationPath.removeLast()
            }
        }
    
    
//    private func createChatRoom(from post: LocationPost) -> ChatRoom {
//        return ChatRoom(
//            name: post.title ?? "",  // 因为 title 是可选的，所以需要提供默认值
//            lastMessage: "新的对话",
//            time: formatCurrentTime(),
//            avatar: post.thumbnailImage,  // 使用计算属性 thumbnailImage
//            isGroupChat: post.participantsCount > 2
//        )
//    }
//
//      
//      // 辅助方法：格式化当前时间
//      private func formatCurrentTime() -> String {
//          let formatter = DateFormatter()
//          formatter.dateFormat = "HH:mm"
//          return formatter.string(from: Date())
//      }
//    
    
    
    
    
    
    func resetNavigation() {
        chatNavigationSource = .normal
        selectedTab = .home
        pendingChatRoom = nil
        navigationPath.removeLast(navigationPath.count)
        isPresentingSheet = false
        presentedSheet = nil
    }

    // MARK: - UI State Control
    func setNavigationBarVisibility(_ isHidden: Bool) {
        isNavigationBarHidden = isHidden
    }
    
    func setTabBarVisibility(_ isHidden: Bool) {
        isTabBarHidden = isHidden
    }
    
}

