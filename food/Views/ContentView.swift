import SwiftUI

// 首先创建一个用户认证状态管理器
final class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool
    @Published var userProfile: UserProfile?
    
    struct UserProfile: Codable {
        let userId: String
        let userName: String
      
    }
    
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

struct ContentView: View {
    @StateObject private var tabBarManager = TabBarManager()
    @StateObject private var authManager = AuthManager()
    
    var body: some View {
        Group {
            if authManager.isLoggedIn {
                HomeView()
                    .environmentObject(tabBarManager)
                    .environmentObject(authManager) // 传递 authManager 以便可以登出
            } else {
                HomeLoginView()
                    .environmentObject(tabBarManager)
                    .environmentObject(authManager) // 传递 authManager 以便可以登录
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TabBarManager())
    }
}

// 在登录成功的地方调用：
// authManager.signIn()

// 在需要登出的地方调用：
// authManager.signOut()
