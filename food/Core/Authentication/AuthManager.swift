//
//  AuthManager.swift
//  food
//
//  Created by toyousoft on 2024/11/03.
//

import SwiftUI

final class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool
    @Published var userProfile: UserProfile?
    
    init() {
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        if let userData = UserDefaults.standard.data(forKey: "userProfile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: userData) {
            self.userProfile = profile
        }
    }
    
    func signIn(profile: UserProfile) {
        isLoggedIn = true
        userProfile = profile
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "userProfile")
        }
    }
    
    func signOut() {
        isLoggedIn = false
        userProfile = nil
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "userProfile")
    }
}
