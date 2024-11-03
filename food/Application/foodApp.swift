//
//  foodApp.swift
//  food
//
//  Created by Abu Anwar MD Abdullah on 25/1/21.
//

import SwiftUI

@main
struct foodApp: App {
    @StateObject private var tabBarManager = TabBarManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tabBarManager)
               
        }
    }
}
