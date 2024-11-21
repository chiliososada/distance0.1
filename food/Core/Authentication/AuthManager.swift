import SwiftUI
import FirebaseAuth
import Combine

final class AuthManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var currentUser: User?
    @Published private(set) var userProfile: UserProfile?
    @Published private(set) var isLoading = false
    @Published private(set) var error: AuthError?
    
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
   
    
    @MainActor
    func validateCurrentSession() async throws -> Bool {
        guard let user = currentUser else {
            return false
        }
        
        do {
            // 尝试刷新用户状态
            try await user.reload()
            
            // 验证邮箱
            if !user.isEmailVerified {
                throw AuthError.emailNotVerified
            }
            
            // 尝试获取新token，这会自动验证会话
            _ = try await user.getIDToken()
            
            // 更新用户档案
            let profile = try await createUserProfile(from: user)
            self.userProfile = profile
            await sessionManager.updateSession(user: profile)
            
            return true
        } catch {
            self.error = AuthError.fromFirebaseError(error)
            return false
        }
    }
    
    private func setupAuthStateListener() {
        stateListener = auth.addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                if let user = user {
                    // 用户已登录，创建或获取用户档案
                    if user.isEmailVerified {
                        do {
                            let profile = try await self?.createUserProfile(from: user)
                            self?.userProfile = profile
                            await self?.sessionManager.updateSession(user: profile)
                        } catch {
                            self?.error = AuthError.fromFirebaseError(error)
                        }
                    }
                } else {
                    // 用户已登出
                    self?.userProfile = nil
                    await self?.sessionManager.clearSession()
                }
            }
        }
    }
    
    // MARK: - Public Methods
    @MainActor
      func signIn(with credentials: AuthCredentials) async throws {
          isLoading = true
          error = nil
          
          defer {
              isLoading = false
          }
          
          do {
              let result = try await auth.signIn(withEmail: credentials.email, password: credentials.password)
              if !result.user.isEmailVerified {
                  throw AuthError.emailNotVerified
              }
          } catch {
              self.error = AuthError.fromFirebaseError(error)
              throw self.error!
          }
      }
    
    @MainActor
        func signUp(with data: RegistrationData) async throws {
            isLoading = true
            error = nil
            
            defer {
                isLoading = false
            }
            
            do {
                let result = try await auth.createUser(withEmail: data.email, password: data.password)
                try await updateUserProfile(result.user, name: data.name)
                try await result.user.sendEmailVerification()
            } catch {
                self.error = AuthError.fromFirebaseError(error)
                throw self.error!
            }
        }
        
        @MainActor
        func signOut() async throws {
            isLoading = true
            error = nil
            
            defer {
                isLoading = false
            }
            
            do {
                try auth.signOut()
                await sessionManager.clearSession()
            } catch {
                self.error = AuthError.fromFirebaseError(error)
                throw self.error!
            }
        }
        
        @MainActor
        func updatePassword(currentPassword: String, newPassword: String) async throws {
            isLoading = true
            error = nil
            
            defer {
                isLoading = false
            }
            
            do {
                guard let user = auth.currentUser else {
                    throw AuthError.userNotFound
                }
                
                let credential = EmailAuthProvider.credential(
                    withEmail: user.email ?? "",
                    password: currentPassword
                )
                try await user.reauthenticate(with: credential)
                try await user.updatePassword(to: newPassword)
                
                await sessionManager.clearSession()
                try auth.signOut()
            } catch {
                self.error = AuthError.fromFirebaseError(error)
                throw self.error!
            }
        }
        
        @MainActor
        func deleteAccount(password: String) async throws {
            isLoading = true
            error = nil
            
            defer {
                isLoading = false
            }
            
            do {
                guard let user = auth.currentUser else {
                    throw AuthError.userNotFound
                }
                
                try await reauthenticateUser(user, with: password)
                try await user.delete()
                await sessionManager.clearSession()
            } catch {
                self.error = AuthError.fromFirebaseError(error)
                throw self.error!
            }
        }
    
    // MARK: - Private Helper Methods
    private func createUserProfile(from user: User) async throws -> UserProfile {
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
    
    deinit {
        if let listener = stateListener {
            auth.removeStateDidChangeListener(listener)
        }
    }
}
