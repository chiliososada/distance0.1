import SwiftUI
import FirebaseAuth
import Combine

final class AuthManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var currentUser: User?
    @Published private(set) var userProfile: UserProfile?
    @Published private(set) var isLoading = false
    @Published private(set) var error: AuthError?
    @Published private(set) var isInitialized = false
    
    // MARK: - Dependencies
    private let auth = Auth.auth()
    private let sessionManager: SessionManager
    private var stateListener: AuthStateDidChangeListenerHandle?
    
    // MARK: - Initialization
    init(sessionManager: SessionManager = .shared) {
        print("AuthManager initialized")
        self.sessionManager = sessionManager
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        stateListener = auth.addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                guard let self = self else { return }
                
                self.currentUser = user
                
                if !self.isInitialized {
                    // 尝试从会话管理器加载用户配置文件
                    self.userProfile = self.sessionManager.getSavedProfile()
                    self.isInitialized = true
                }
            }
        }
    }
    
    // MARK: - Public Methods
    @MainActor
    func validateCurrentSession() async throws -> Bool {
        // 首先检查本地令牌是否存在
        if sessionManager.getAuthToken() == nil {
            return false  // 如果没有令牌，直接返回false
        }
        
        do {
            // 通过API验证会话有效性
            let isValid = try await UserService.shared.checkSession()
            
            if isValid {
                // 如果会话有效，确保加载用户配置文件
                if let profile = sessionManager.getSavedProfile() {
                    self.userProfile = profile
                    return true
                } else if sessionManager.shouldRefreshProfile() {
                    // 如果需要刷新用户配置文件，可以在这里实现
                    // 目前暂时返回true因为会话本身有效
                    return true
                }
            }
            
            // 会话无效，清理本地状态
            await sessionManager.clearSession()
            self.userProfile = nil
            return false
        } catch {
            print("Session validation error: \(error.localizedDescription)")
            // 出现错误时，保守处理为会话无效
            await sessionManager.clearSession()
            self.userProfile = nil
            return false
        }
    }
    
    @MainActor
    func signIn(with credentials: AuthCredentials) async throws {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            // 1. Firebase 认证
            let result = try await auth.signIn(withEmail: credentials.email, password: credentials.password)
            
            // 2. 检查邮箱验证
            if !result.user.isEmailVerified {
                // 如果未验证，发送验证邮件
                try await result.user.sendEmailVerification()
                throw AuthError.emailNotVerified
            }
            
            // 3. 获取 idToken
            let idToken = try await result.user.getIDToken()
            
            // 4. 调用后端API进行真正的登录
            let userProfile = try await signInWithBackend(idToken: idToken)
            
            // 5. 存储session信息
            self.userProfile = userProfile
            await sessionManager.updateSessionWithToken(idToken: idToken, profile: userProfile)
            
            // 6. 退出Firebase认证
            try auth.signOut()
            
        } catch {
            self.error = AuthError.fromFirebaseError(error)
            throw self.error!
        }
    }
    
    @MainActor
    func signUp(with data: RegistrationData) async throws {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            // 1. 创建用户
            let result = try await auth.createUser(withEmail: data.email, password: data.password)
            
            // 2. 更新用户资料
            try await updateUserProfile(result.user, name: data.name)
            
            // 3. 发送验证邮件
            try await result.user.sendEmailVerification()
            
            // 4. 注册完成后退出Firebase
            try auth.signOut()
            
        } catch {
            self.error = AuthError.fromFirebaseError(error)
            throw self.error!
        }
    }
    
    @MainActor
    func signOut() async throws {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            // 1. 清除session
            await sessionManager.clearSession()
            
            // 2. 清除本地状态
            self.userProfile = nil
            
            // 3. Firebase 登出（以防万一）
            if auth.currentUser != nil {
                try auth.signOut()
            }
        } catch {
            self.error = AuthError.fromFirebaseError(error)
            throw self.error!
        }
    }
    
    @MainActor
    func updatePassword(currentPassword: String, newPassword: String) async throws {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            // 由于已经不使用Firebase管理认证，需要调用自己的API
            try await updatePasswordWithBackend(currentPassword: currentPassword, newPassword: newPassword)
            
            // 成功后清除session，强制用户重新登录
            await sessionManager.clearSession()
            self.userProfile = nil
            
        } catch {
            self.error = error as? AuthError ?? AuthError.unknown(error.localizedDescription)
            throw self.error!
        }
    }
    
    @MainActor
    func deleteAccount(password: String) async throws {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            // 调用后端API删除账户
            try await deleteAccountWithBackend(password: password)
            
            // 清除session
            await sessionManager.clearSession()
            self.userProfile = nil
            
        } catch {
            self.error = error as? AuthError ?? AuthError.unknown(error.localizedDescription)
            throw self.error!
        }
    }
    
    // MARK: - Private Methods
    private func updateUserProfile(_ user: User, name: String) async throws {
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = name
        try await changeRequest.commitChanges()
    }
    
    private func signInWithBackend(idToken: String) async throws -> UserProfile {
        return try await UserService.shared.loginWithFirebaseToken(idToken)
    }
    
    private func updatePasswordWithBackend(currentPassword: String, newPassword: String) async throws {
        try await UserService.shared.updatePassword(currentPassword: currentPassword, newPassword: newPassword)
    }
    
    private func deleteAccountWithBackend(password: String) async throws {
        try await UserService.shared.deleteAccount(password: password)
    }
    
    deinit {
        if let listener = stateListener {
            auth.removeStateDidChangeListener(listener)
        }
    }
}
