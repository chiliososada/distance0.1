//
//  AuthManagers.swift
//  food
//
//  Created by toyousoft on 2024/11/13.
//
import SwiftUI
import FirebaseAuth
import Combine
// MARK: - Core Auth Manager
final class AuthManager: ObservableObject {
    // MARK: - Published State
    @Published private(set) var state: AuthState = .initial
    
    // MARK: - Dependencies
    private let userDefaults: UserDefaults
    private let auth = Auth.auth()
    private let sessionManager: SessionManager
   
    
    // MARK: - Initialization
    init(
        userDefaults: UserDefaults = .standard,
        sessionManager: SessionManager = .shared
       
    ) {
        self.userDefaults = userDefaults
        self.sessionManager = sessionManager
       
        
        // 初始状态检查
        checkInitialState()
    }
    
    // MARK: - Public Methods
    
    /// 登录方法
    @MainActor
    func signIn(with credentials: AuthCredentials) async throws {
        print("AuthManager: Starting sign in for \(credentials.email)")
        setState(.loading)
        
        do {
            print("AuthManager: Attempting Firebase sign in")
            let result = try await auth.signIn(withEmail: credentials.email, password: credentials.password)
            print("AuthManager: Firebase sign in successful")
            
            let profile = try await createUserProfile(from: result.user)
            print("AuthManager: User profile created")
            
            if result.user.isEmailVerified {
                print("AuthManager: Email is verified, completing authentication")
                await completeAuthentication(with: profile)
                print("AuthManager: Authentication completed, final state: \(state)")
            } else {
                print("AuthManager: Email is not verified")
                setState(.emailUnverified(credentials.email))
            }
        } catch {
            print("AuthManager: Sign in error - \(error.localizedDescription)")
            let authError = AuthError.fromFirebaseError(error)
            setState(.error(authError))
            throw authError
        }
    }
    
    /// 注册方法
    @MainActor
    func signUp(with data: RegistrationData) async throws {
        setState(.loading)
        
        do {
            print("Starting user registration for email: \(data.email)")
            
            // 创建用户
            let result = try await auth.createUser(withEmail: data.email, password: data.password)
            print("User created successfully: \(result.user.uid)")
            
            // 更新用户资料
            try await updateUserProfile(result.user, name: data.name)
            print("User profile updated")
            
            // 发送验证邮件
            try await result.user.sendEmailVerification()
            print("Verification email sent")
            
            // 创建用户配置文件
            let profile = try await createUserProfile(from: result.user)
            print("User profile created")
            
            // 更新会话
            await sessionManager.updateSession(user: profile)
            print("Session updated")
            
            // 设置状态为待验证，并确保不会被覆盖
            setState(.emailUnverified(data.email))
            print("Final state set to emailUnverified")
            
        } catch {
            print("Registration error: \(error.localizedDescription)")
            let authError = AuthError.fromFirebaseError(error)
            setState(.error(authError))
            throw authError
        }
    }
    
    /// 退出登录
    @MainActor
    func signOut() async throws {
        setState(.loading)
        
        do {
            try auth.signOut()
            await sessionManager.clearSession()
            setState(.unauthenticated)
        } catch {
            let authError = AuthError.fromFirebaseError(error)
            setState(.error(authError))
            throw authError
        }
    }
    
    @MainActor
    func updatePassword(currentPassword: String, newPassword: String) async throws {
        setState(.loading)
        
        do {
            guard let user = auth.currentUser else {
                throw AuthError.userNotFound
            }
            
            // 重新认证用户
            let credential = EmailAuthProvider.credential(
                withEmail: user.email ?? "",
                password: currentPassword
            )
            try await user.reauthenticate(with: credential)
            
            // 更新密码
            try await user.updatePassword(to: newPassword)
            
            // 清除当前会话
            await sessionManager.clearSession()
            
            // 注销当前用户
            try auth.signOut()
            
            // 将状态设置为未认证
            setState(.unauthenticated)
            
        } catch {
            let authError = AuthError.fromFirebaseError(error)
            setState(.error(authError))
            throw authError
        }
    }
    /// 删除账户
    @MainActor
    func deleteAccount(password: String) async throws {
        setState(.loading)
        
        do {
            guard let user = auth.currentUser else {
                throw AuthError.userNotFound
            }
            
            // 重新验证
            try await reauthenticateUser(user, with: password)
            
            // 删除账户
            try await user.delete()
            await sessionManager.clearSession()
            setState(.unauthenticated)
        } catch {
            let authError = AuthError.fromFirebaseError(error)
            setState(.error(authError))
            throw authError
        }
    }
    
    /// 检查邮箱验证状态
    @MainActor
    func checkEmailVerification() async throws {
        guard case .emailUnverified(let email) = state else { return }
        
        do {
            guard let user = auth.currentUser else {
                throw AuthError.userNotFound
            }
            
            try await user.reload()
            
            if user.isEmailVerified {
                let profile = try await createUserProfile(from: user)
                await completeAuthentication(with: profile)
            }
        } catch {
            let authError = AuthError.fromFirebaseError(error)
            setState(.error(authError))
            throw authError
        }
    }
    
    // MARK: - Private Methods
    
    private func setState(_ newState: AuthState) {
        DispatchQueue.main.async { [weak self] in
            self?.state = newState
        }
    }
    
    private func checkInitialState() {
        if let user = auth.currentUser {
            Task { @MainActor in
                do {
                    try await user.reload()
                    let profile = try await createUserProfile(from: user)
                    
                    if user.isEmailVerified {
                        await completeAuthentication(with: profile)
                    } else {
                        setState(.emailUnverified(user.email ?? ""))
                    }
                } catch {
                    setState(.unauthenticated)
                }
            }
        } else {
            setState(.unauthenticated)
        }
    }
    
    private func createUserProfile(from user: User) async throws -> UserProfile {
        // 从 Firestore 获取用户数据或创建新的配置文件
        return UserProfile(
            id: user.uid,
            userName: user.displayName ?? user.email?.components(separatedBy: "@").first ?? "User",
            email: user.email,
            createdAt: user.metadata.creationDate ?? Date(),
            lastUpdated: Date(),
            settings: UserProfile.Settings(
                nickname: user.displayName ?? "New User",
                bio: "",
                idNumber: user.uid,
                gender: .preferNotToSay,
                birthDate: Date(),
                notificationsEnabled: true,
                privacySettings: .init(
                    isProfilePublic: true,
                    showLocation: true,
                    showOnlineStatus: true
                )
            ),
            stats: .init(
                participantsCount: 0,
                viewedTopicsCount: 0,
                postsCount: 0,
                followersCount: 0,
                followingCount: 0
            )
        )
    }
    
    @MainActor
    private func completeAuthentication(with profile: UserProfile) async {
        print("Starting complete authentication")
        await sessionManager.updateSession(user: profile)
        print("Session updated")
        setState(.authenticated(profile))
        print("State set to authenticated")
    }
    
    private func updateUserProfile(_ user: User, name: String) async throws {
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = name
        try await changeRequest.commitChanges()
    }
    
    private func reauthenticateUser(_ user: User, with password: String) async throws {
        guard let email = user.email else {
            throw AuthError.userNotFound
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await user.reauthenticate(with: credential)
    }
    private func handleError(_ error: Error) throws -> Never {
            let authError = AuthError.fromFirebaseError(error)
            setState(.error(authError))
            throw authError
        }
}



