import SwiftUI



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
