import SwiftUI

class TabBarManager: ObservableObject {
    @Published var isViewTabBarHidden: Bool = false
    @Published var isNavigatingInTab: Bool = false  // 新增：标记是否在 tab 内导航
}
