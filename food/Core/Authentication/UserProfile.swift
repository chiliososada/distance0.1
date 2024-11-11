//
//  UserProfile.swift
//  food
//

import Foundation

// MARK: - User Profile Model
struct UserProfile: Codable, Identifiable {
    // MARK: - Core Properties
    let id: String
    var userName: String
    var email: String?
    var phoneNumber: String?
    var location: String?
    var bio: String?
    var avatarUrl: String?
    let createdAt: Date
    var lastUpdated: Date
    
    // MARK: - Settings
    var settings: Settings
    var stats: UserStats
    
    // MARK: - Nested Types
    struct Settings: Codable {
        var nickname: String
        var bio: String
        var idNumber: String
        var gender: Gender
        var birthDate: Date
        var notificationsEnabled: Bool
        var privacySettings: PrivacySettings
        
        struct PrivacySettings: Codable {
            var isProfilePublic: Bool
            var showLocation: Bool
            var showOnlineStatus: Bool
        }
    }
    
    struct UserStats: Codable {
        var participantsCount: Int
        var viewedTopicsCount: Int
        var postsCount: Int
        var followersCount: Int
        var followingCount: Int
        
        var formattedParticipantsCount: String {
            formatCount(participantsCount)
        }
        
        var formattedViewedTopicsCount: String {
            formatCount(viewedTopicsCount)
        }
        
        private func formatCount(_ count: Int) -> String {
            if count >= 1_000_000 {
                return String(format: "%.1fM+", Double(count) / 1_000_000)
            } else if count >= 1_000 {
                return String(format: "%.1fK+", Double(count) / 1_000)
            }
            return "\(count)"
        }
    }
    
    // MARK: - Gender Enum
    enum Gender: String, Codable, CaseIterable {
        case male = "male"
        case female = "female"
        case other = "other"
        case preferNotToSay = "preferNotToSay"
        
        var localizedString: String {
            switch self {
            case .male: return "男"
            case .female: return "女"
            case .other: return "その他"
            case .preferNotToSay: return "回答しない"
            }
        }
    }
    
    // MARK: - Initialization
    init(id: String,
         userName: String,
         email: String? = nil,
         phoneNumber: String? = nil,
         location: String? = nil,
         bio: String? = nil,
         avatarUrl: String? = nil,
         createdAt: Date = Date(),
         lastUpdated: Date = Date(),
         settings: Settings,
         stats: UserStats) {
        self.id = id
        self.userName = userName
        self.email = email
        self.phoneNumber = phoneNumber
        self.location = location
        self.bio = bio
        self.avatarUrl = avatarUrl
        self.createdAt = createdAt
        self.lastUpdated = lastUpdated
        self.settings = settings
        self.stats = stats
    }
    
    // MARK: - Helper Methods
    func formattedJoinDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return "加入日: \(formatter.string(from: createdAt))"
    }
    
    // MARK: - Sample Data
    static var sample: UserProfile {
        UserProfile(
            id: "user123",
            userName: "liu ziyuan",
            email: "example@email.com",
            location: "東京都 葛飾区 立石",
            bio: "我是一个专注于前端开发的程序员",
            avatarUrl: "sample1",
            settings: Settings(
                nickname: "东京 it 小白",
                bio: "美妙的生活由此开始~",
                idNumber: "178385",
                gender: .male,
                birthDate: Date(),
                notificationsEnabled: true,
                privacySettings: Settings.PrivacySettings(
                    isProfilePublic: true,
                    showLocation: true,
                    showOnlineStatus: true
                )
            ),
            stats: UserStats(
                participantsCount: 1200,
                viewedTopicsCount: 1500000,
                postsCount: 42,
                followersCount: 358,
                followingCount: 285
            )
        )
    }
}
