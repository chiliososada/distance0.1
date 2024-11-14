//import SwiftUI
//import Combine
//import FirebaseAuth
//import FirebaseCore
//
//// MARK: - Auth Manager
//final class AuthManager: ObservableObject {
//    // MARK: - Published Properties
//    @Published private(set) var isLoggedIn: Bool = false
//    @Published private(set) var isEmailVerified: Bool = false  // 添加邮箱验证状态
//    // private var shouldAutoLogin = true  // 添加控制标志
//    @Published private(set) var userProfile: UserProfile?
//    @Published private(set) var authenticationState: AuthenticationState = .idle
//    @Published private(set) var isLoading: Bool = false
//    
//    // MARK: - Private Properties
//    private let userDefaults: UserDefaults
//    private var cancellables = Set<AnyCancellable>()
//    private let auth = Auth.auth()
//    
//    // MARK: - Constants
//    private enum Constants {
//        static let isLoggedInKey = "isLoggedIn"
//        static let userProfileKey = "userProfile"
//        static let tokenKey = "authToken"
//    }
//    
//    // MARK: - Authentication State
//    enum AuthenticationState {
//        case idle
//        case authenticating
//        case authenticated
//        case failed(Error)
//        case loggedOut
//    }
//    
//    // MARK: - Initialization
//    init(userDefaults: UserDefaults = .standard) {
//        self.userDefaults = userDefaults
//        
//        if auth.currentUser == nil {
//            clearAuthState()
//        }
//        loadUserProfile()
//    }
//    
//    
//    
//    /// 删除当前用户账户
//    @MainActor
//    func deleteAccount(password: String) async throws {
//        setLoading(true)
//        defer { setLoading(false) }
//        
//        guard let user = Auth.auth().currentUser else {
//            throw AuthError.noUserFound
//        }
//        
//        do {
//            // 1. 先重新验证用户
//            try await reauthenticateUser(with: password)
//            
//            // 2. 删除账户
//            try await user.delete()
//            
//            // 3. 使用与 signOut 相同的状态更新方法
//            updateStateOnMain()
//            
////            // 4. 通知其他组件账户已被删除
////            NotificationCenter.default.post(
////                name: NSNotification.Name("UserAccountDeleted"),
////                object: nil
////            )
//            
//        } catch let error as NSError {
//            switch error.code {
//            case AuthErrorCode.wrongPassword.rawValue:
//                throw AuthError.invalidPassword
//            case AuthErrorCode.networkError.rawValue:
//                throw AuthError.networkError
//            case AuthErrorCode.requiresRecentLogin.rawValue:
//                throw AuthError.unknown("需要重新登录后再试")
//            default:
//                handleAuthError(error)
//                throw error
//            }
//        }
//    }
//
//    
//    
//    @MainActor
//    func reauthenticateUser(with password: String) async throws {
//        setLoading(true)
//        defer { setLoading(false) }
//        
//        guard let user = Auth.auth().currentUser,
//              let email = user.email else {
//            throw AuthError.noUserFound
//        }
//        
//        do {
//            let credential = EmailAuthProvider.credential(
//                withEmail: email,
//                password: password
//            )
//            try await user.reauthenticate(with: credential)
//        } catch let error as NSError {
//            switch error.code {
//            case AuthErrorCode.wrongPassword.rawValue:
//                throw AuthError.invalidPassword
//            case AuthErrorCode.tooManyRequests.rawValue:
//                throw AuthError.tooManyRequests
//            case AuthErrorCode.networkError.rawValue:
//                throw AuthError.networkError
//            default:
//                handleAuthError(error)
//                throw AuthError.unknown(error.localizedDescription)
//            }
//        }
//    }
//    
//    /// 更新密码（包含重新验证）
//    @MainActor
//    func updatePassword(currentPassword: String, newPassword: String) async throws {
//        setLoading(true)
//        defer { setLoading(false) }
//        
//        guard let user = Auth.auth().currentUser else {
//            throw AuthError.noUserFound
//        }
//        
//        do {
//            // 1. 先重新验证用户
//            try await reauthenticateUser(with: currentPassword)
//            
//            // 2. 验证成功后更新密码
//            try await user.updatePassword(to: newPassword)
//        } catch let error as NSError {
//            switch error.code {
//            case AuthErrorCode.weakPassword.rawValue:
//                throw AuthError.weakPassword
//            default:
//                handleAuthError(error)
//                throw error
//            }
//        }
//    }
//    // MARK: - Public Methods
//    
//    @MainActor
//    func signIn(email: String, password: String) async throws {
//        setLoading(true)
//        authenticationState = .authenticating
//        
//        do {
//            let result = try await auth.signIn(withEmail: email, password: password)
//            
//            let profile = UserProfile(
//                id: result.user.uid,
//                userName: result.user.displayName ?? email.components(separatedBy: "@").first ?? "User",
//                email: email,
//                createdAt: result.user.metadata.creationDate ?? Date(),
//                lastUpdated: Date(),
//                settings: UserProfile.Settings(
//                    nickname: result.user.displayName ?? "New User",
//                    bio: "",
//                    idNumber: result.user.uid,
//                    gender: .preferNotToSay,
//                    birthDate: Date(),
//                    notificationsEnabled: true,
//                    privacySettings: UserProfile.Settings.PrivacySettings(
//                        isProfilePublic: true,
//                        showLocation: true,
//                        showOnlineStatus: true
//                    )
//                ),
//                stats: UserProfile.UserStats(
//                    participantsCount: 0,
//                    viewedTopicsCount: 0,
//                    postsCount: 0,
//                    followersCount: 0,
//                    followingCount: 0
//                )
//            )
//            
//            await MainActor.run { [weak self] in
//                guard let self = self else { return }
//                self.userProfile = profile
//                self.isLoggedIn = true
//                self.saveUserState()
//                self.authenticationState = .authenticated
//            }
//            
//        } catch {
//            await MainActor.run { [weak self] in
//                self?.handleAuthError(error)
//            }
//            throw error
//        }
//        
//        setLoading(false)
//    }
//    
//    @MainActor
//    func signUp(email: String, password: String, name: String) async throws {
//        setLoading(true)
//        authenticationState = .authenticating
//        
//        do {
//            let result = try await auth.createUser(withEmail: email, password: password)
//            
//            let changeRequest = result.user.createProfileChangeRequest()
//            changeRequest.displayName = name
//            try await changeRequest.commitChanges()
//            
//            try await result.user.sendEmailVerification()
//            
//            let profile = UserProfile(
//                id: result.user.uid,
//                userName: name,
//                email: email,
//                createdAt: Date(),
//                lastUpdated: Date(),
//                settings: UserProfile.Settings(
//                    nickname: name,
//                    bio: "",
//                    idNumber: result.user.uid,
//                    gender: .preferNotToSay,
//                    birthDate: Date(),
//                    notificationsEnabled: true,
//                    privacySettings: UserProfile.Settings.PrivacySettings(
//                        isProfilePublic: true,
//                        showLocation: true,
//                        showOnlineStatus: true
//                    )
//                ),
//                stats: UserProfile.UserStats(
//                    participantsCount: 0,
//                    viewedTopicsCount: 0,
//                    postsCount: 0,
//                    followersCount: 0,
//                    followingCount: 0
//                )
//            )
//            
//            await MainActor.run { [weak self] in
//                guard let self = self else { return }
//                self.userProfile = profile
//                self.isLoggedIn = true
//                self.saveUserState()
//                self.authenticationState = .authenticated
//            }
//            
//        } catch {
//            await MainActor.run { [weak self] in
//                self?.handleAuthError(error)
//            }
//            throw error
//        }
//        setLoading(false)
//        
//    }
//    
//    @MainActor
//    func resetPassword(for email: String) async throws {
//        setLoading(true)
//        defer { setLoading(false) }
//        
//        do {
//            try await Auth.auth().sendPasswordReset(withEmail: email)
//        } catch {
//            handleAuthError(error)
//            throw error
//        }
//    }
//    
//    @MainActor
//    func signOut() throws {
//        setLoading(true)
//        defer { setLoading(false) }
//        
//        do {
//            try auth.signOut()
//            updateStateOnMain()
//        } catch {
//            handleAuthError(error)
//            throw error
//        }
//    }
//    
//    @MainActor
//    func refreshUserStatus() async {
//        print("Refreshing user status")
//        if let user = Auth.auth().currentUser {
//            do {
//               
//                try await user.reload()
//                print("Reloading user: \(user.uid)")
//                isLoggedIn = true
//                isEmailVerified = user.isEmailVerified
//            } catch {
//                print("Error reloading user: \(error)")
//                clearAuthState()
//            }
//        } else {
//            print("No current user found")
//            clearAuthState()
//        }
//    }
//    
//    
//    
//    
//    // 添加检查邮箱验证状态的方法
//    @MainActor
//    func checkEmailVerification() async {
//        print("Checking email verification status")
//        guard let user = Auth.auth().currentUser else {
//            print("No user found in Auth")
//            isEmailVerified = false
//            return
//        }
//        
//        do {
//           
//            try await user.reload()
//            print("Reloading user: \(user.uid)")
//            if let updatedUser = Auth.auth().currentUser {
//                isEmailVerified = updatedUser.isEmailVerified
//                print("Updated verification status: \(isEmailVerified)")
//            } else {
//                print("User not found after reload")
//                isEmailVerified = false
//            }
//        } catch {
//            print("Failed to check email verification: \(error)")
//            isEmailVerified = false
//        }
//    }
//    
//    @MainActor
//    func checkAuthState() async {
//        do {
//            if let user = auth.currentUser {
//                try await user.reload()
//                // 检查用户是否存在
//                if user.uid.isEmpty {
//                    clearAuthState()
//                    return
//                }
//                isLoggedIn = true
//                isEmailVerified = user.isEmailVerified
//            } else {
//                clearAuthState()
//            }
//        } catch {
//            clearAuthState()
//        }
//    }
//    
//    
//    
//    /// 更新推送令牌
//    @MainActor
//    func updatePushToken(_ token: String) async throws {
//        guard let user = auth.currentUser else {
//            throw AuthError.noUserFound
//        }
//        
//        do {
//            // 保存令牌到 UserDefaults
//            userDefaults.set(token, forKey: AppConstants.UserDefaultsKeys.pushToken)
//            userDefaults.synchronize()
//            
//            // 这里可以添加将令牌更新到你的后端服务器的代码
//            /*
//             Example:
//             let data = ["pushToken": token]
//             try await updateUserData(userId: user.uid, data: data)
//             */
//            
//            print("Push token updated successfully: \(token)")
//        } catch {
//            print("Failed to update push token: \(error.localizedDescription)")
//            throw AuthError.unknown("Failed to update push token")
//        }
//    }
//    
//    /// 获取当前保存的推送令牌
//    func getCurrentPushToken() -> String? {
//        return userDefaults.string(forKey: AppConstants.UserDefaultsKeys.pushToken)
//    }
//    
//    /// 清除推送令牌
//    @MainActor
//    func clearPushToken() {
//        userDefaults.removeObject(forKey: AppConstants.UserDefaultsKeys.pushToken)
//        userDefaults.synchronize()
//    }
//    
//    // 在 clearAuthState 方法中添加清除推送令牌的操作
//    func updateStateOnMain() {
//        if Thread.isMainThread {
//            isLoggedIn = false
//            isEmailVerified = false
//            userProfile = nil
//            authenticationState = .loggedOut
//            
//            // 清除所有存储的数据
//            userDefaults.removeObject(forKey: AppConstants.UserDefaultsKeys.isLoggedIn)
//            userDefaults.removeObject(forKey: AppConstants.UserDefaultsKeys.userProfile)
//            userDefaults.removeObject(forKey: AppConstants.UserDefaultsKeys.authToken)
//            userDefaults.removeObject(forKey: AppConstants.UserDefaultsKeys.pushToken)
//            userDefaults.removeObject(forKey: "hasCompletedInitialLaunch")
//            userDefaults.synchronize()
//        } else {
//            DispatchQueue.main.async { [weak self] in
//                self?.updateStateOnMain()
//            }
//        }
//    }
//    private func clearAuthState() {
//        if Thread.isMainThread {
//            updateStateOnMain()
//        } else {
//            DispatchQueue.main.async { [weak self] in
//                self?.updateStateOnMain()
//            }
//        }
//    }
//    
//    
//    private func handleAuthError(_ error: Error) {
//        DispatchQueue.main.async { [weak self] in
//            self?.setLoading(false)
//            let authError: AuthError = self?.handleFirebaseError(error) as? AuthError ?? .unknown("Unknown error occurred")
//            self?.authenticationState = .failed(authError)
//        }
//    }
//    
//    
//    
//    private func setLoading(_ loading: Bool) {
//        DispatchQueue.main.async { [weak self] in
//            self?.isLoading = loading
//        }
//    }
//    
//    private func saveUserState() {
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//            self.userDefaults.set(true, forKey: AppConstants.UserDefaultsKeys.isLoggedIn)
//            if let encoded = try? JSONEncoder().encode(self.userProfile) {
//                self.userDefaults.set(encoded, forKey: AppConstants.UserDefaultsKeys.userProfile)
//            }
//            self.userDefaults.synchronize()
//        }
//    }
//    
//    private func loadUserProfile() {
//        if let userData = userDefaults.data(forKey: AppConstants.UserDefaultsKeys.userProfile),
//           let profile = try? JSONDecoder().decode(UserProfile.self, from: userData) {
//            DispatchQueue.main.async { [weak self] in
//                self?.userProfile = profile
//            }
//        }
//    }
//    
//    private func handleFirebaseError(_ error: Error) -> AuthError {
//        let nsError = error as NSError
//        print("Firebase error code: \(nsError.code), description: \(error.localizedDescription)")
//        
//        switch nsError.code {
//        case AuthErrorCode.invalidEmail.rawValue:
//            return .invalidEmail
//        case AuthErrorCode.wrongPassword.rawValue:
//            return .invalidPassword
//        case AuthErrorCode.userNotFound.rawValue:
//            return .noUserFound
//        case AuthErrorCode.emailAlreadyInUse.rawValue:
//            return .duplicateEmail
//        case AuthErrorCode.weakPassword.rawValue:
//            return .weakPassword
//        case AuthErrorCode.networkError.rawValue:
//            return .networkError
//        case AuthErrorCode.tooManyRequests.rawValue:
//            return .tooManyRequests
//        default:
//            return .unknown(error.localizedDescription)
//        }
//    }
//}
//
//// MARK: - Custom Auth Errors
//enum AuthError: LocalizedError {
//    case invalidEmail
//    case invalidPassword
//    case noUserFound
//    case duplicateEmail
//    case weakPassword
//    case networkError
//    case tooManyRequests
//    case unknown(String)
//    
//    var errorDescription: String? {
//        switch self {
//        case .invalidEmail:
//            return "邮箱格式无效"
//        case .invalidPassword:
//            return "密码错误"
//        case .noUserFound:
//            return "用户不存在"
//        case .duplicateEmail:
//            return "该邮箱已被注册"
//        case .weakPassword:
//            return "密码强度不够，至少需要6个字符"
//        case .networkError:
//            return "网络连接错误，请检查网络后重试"
//        case .tooManyRequests:
//            return "请求过于频繁，请稍后再试"
//        case .unknown(let message):
//            return "错误: \(message)"
//        }
//    }
//}
//
//// MARK: - Preview Helper
//#if DEBUG
//extension AuthManager {
//    static var preview: AuthManager {
//        let manager = AuthManager(userDefaults: .standard)
//        manager.userProfile = UserProfile.sample
//        return manager
//    }
//}
//#endif
