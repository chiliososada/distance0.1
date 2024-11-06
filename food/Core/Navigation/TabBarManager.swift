import SwiftUI

class TabBarManager: ObservableObject {
    @Published var isNavigatingInTab: Bool = false
    @Published var isViewTabBarHidden: Bool = false

    // 添加更多的控制方法
    func hideTabBar() {
        isNavigatingInTab = true
    }

    func showTabBar() {
        isNavigatingInTab = false
        isViewTabBarHidden = false
    }
    //---
    func setNavigationState(_ isNavigating: Bool) {
            isNavigatingInTab = isNavigating
        }
        
    func resetNavigationState() {
            isNavigatingInTab = false
            isViewTabBarHidden = false
        }
}
