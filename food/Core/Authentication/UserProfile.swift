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
    // 添加新属性
    var chatToken: String?
    var session: String?
    var chatID: [String]?  // 修改为chatID以保持一致性
    var chatUrl: String?

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
        
        init(from backendGender: String?) {
            switch backendGender?.lowercased() {
            case "male", "男":
                self = .male
            case "female", "女":
                self = .female
            case "other", "其他":
                self = .other
            default:
                self = .preferNotToSay
            }
        }
        
        var localizedString: String {
            switch self {
            case .male: return "男"
            case .female: return "女"
            case .other: return "其他"
            case .preferNotToSay: return "不透露"
            }
        }
    }
    
    // MARK: - Initialization
    init(
        id: String,
        userName: String,
        email: String? = nil,
        phoneNumber: String? = nil,
        location: String? = nil,
        bio: String? = nil,
        avatarUrl: String? = nil,
        createdAt: Date = Date(),
        lastUpdated: Date = Date(),
        settings: Settings,
        stats: UserStats,
        chatToken: String? = nil,
        session: String? = nil,
        chatID: [String]? = nil,
        chatUrl: String? = nil
    ) {
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
        self.chatToken = chatToken
        self.session = session
        self.chatID = chatID
        self.chatUrl = chatUrl
    }
    
    // 从后端 UserProfile 初始化的构造方法
    init(backendProfile: BackendUserProfile) {
        self.init(
            id: backendProfile.uid,
            userName: backendProfile.displayName,
            email: backendProfile.email,
            phoneNumber: nil,
            location: nil,
            bio: backendProfile.bio,
            avatarUrl: backendProfile.photoUrl,
            createdAt: Date(),
            lastUpdated: Date(),
            settings: Settings(
                nickname: backendProfile.displayName,
                bio: backendProfile.bio ?? "",
                idNumber: backendProfile.uid,
                gender: Gender(from: backendProfile.gender),
                birthDate: Date(), // 可能需要从后端获取
                notificationsEnabled: true,
                privacySettings: Settings.PrivacySettings(
                    isProfilePublic: true,
                    showLocation: true,
                    showOnlineStatus: true
                )
            ),
            stats: UserStats(
                participantsCount: 0,
                viewedTopicsCount: 0,
                postsCount: 0,
                followersCount: 0,
                followingCount: 0
            ),
            chatToken: backendProfile.chatToken,
            //session: backendProfile.session,
            chatID: backendProfile.chatID,
            chatUrl: backendProfile.chatUrl
        )
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

// 后端返回的用户信息结构体
struct BackendUserProfile: Codable {
    let csrfToken: String
    let uid: String
    let displayName: String
    let photoUrl: String?
    let email: String
    let gender: String?
    let bio: String?
    let chatToken: String
   // let session: String
    let chatID: [String]  // 确保使用chatID（大写ID）
    let chatUrl: String
    
    enum CodingKeys: String, CodingKey {
        case csrfToken = "CsrfToken"
        case uid = "UID"
        case displayName = "DisplayName"
        case photoUrl = "PhotoUrl"
        case email = "Email"
        case gender = "Gender"
        case bio = "Bio"
        case chatToken = "ChatToken"
       // case session = "Session"
        case chatID = "ChatID"  // 映射到大写的ChatID
        case chatUrl = "ChatUrl"
    }
}
