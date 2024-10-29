//
//  foodApp.swift
//  food
//
//  Created by Abu Anwar MD Abdullah on 25/1/21.
//

import SwiftUI

@main
struct foodApp: App {
    // 使用 StateObject 确保 TabBarManager 的生命周期
    @StateObject private var tabBarManager = TabBarManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tabBarManager)
        }
    }
}
