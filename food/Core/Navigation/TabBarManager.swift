import SwiftUI

final class TabBarManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isNavigatingInTab: Bool = false {
        didSet {
            print("TabBarManager: isNavigatingInTab changed to \(isNavigatingInTab)")
        }
    }
    
    @Published var isViewTabBarHidden: Bool = false {
        didSet {
            print("TabBarManager: isViewTabBarHidden changed to \(isViewTabBarHidden)")
        }
    }
    
    // MARK: - Initialization
    init() {
        print("TabBarManager initialized")
    }
    
    // MARK: - Public Methods
    func hideTabBar() {
        print("TabBarManager: Hiding tab bar")
        isNavigatingInTab = true
    }

    func showTabBar() {
        print("TabBarManager: Showing tab bar")
        isNavigatingInTab = false
        isViewTabBarHidden = false
    }
    
    func setNavigationState(_ isNavigating: Bool) {
        print("TabBarManager: Setting navigation state to \(isNavigating)")
        isNavigatingInTab = isNavigating
    }
        
    func resetNavigationState() {
        print("TabBarManager: Resetting navigation state")
        isNavigatingInTab = false
        isViewTabBarHidden = false
    }
    
    // MARK: - Cleanup
    deinit {
        print("TabBarManager deinitialized")
    }
}

// MARK: - Preview Helper
#if DEBUG
extension TabBarManager {
    static var preview: TabBarManager {
        let manager = TabBarManager()
        // 可以设置预览状态
        return manager
    }
}
#endif
