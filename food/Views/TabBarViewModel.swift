//
//  TabBarViewModel.swift
//  food
//
//  Created by toyousoft on 2024/10/10.
//

import SwiftUI

// ViewModel 用于全局控制 TabBar 的显示状态
class TabBarViewModel: ObservableObject {
    @Published var isTabBarHidden: Bool = false
}
