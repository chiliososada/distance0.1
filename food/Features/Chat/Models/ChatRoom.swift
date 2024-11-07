// ChatModels.swift

import Foundation

// MARK: - Chat Room Model
struct ChatRoom: Identifiable, Hashable {
    let id: UUID
    let name: String
    let type: ChatRoomType
    let avatar: String
    var lastMessage: Message?
    var members: [Member]
    var announcement: Announcement?
    var isTopChat: Bool
    
    enum ChatRoomType {
        case individual
        case group
    }
    
    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        name: String,
        type: ChatRoomType,
        avatar: String,
        lastMessage: Message? = nil,
        members: [Member] = [],
        announcement: Announcement? = nil,
        isTopChat: Bool = false
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.avatar = avatar
        self.lastMessage = lastMessage
        self.members = members
        self.announcement = announcement
        self.isTopChat = isTopChat
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ChatRoom, rhs: ChatRoom) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Message Model
struct Message: Identifiable, Equatable {
    let id: UUID
    let sender: Member
    let content: MessageContent
    let timestamp: Date
    let status: MessageStatus
    
    enum MessageStatus: Equatable {
        case sending
        case sent
        case delivered
        case read
        case failed
    }
    
    enum MessageContent: Equatable {
        case text(String)
        case image(URL)
        case file(URL, String) // URL and filename
        case system(String)    // For system messages like "X joined the group"
        
        // 实现 Equatable
        static func == (lhs: MessageContent, rhs: MessageContent) -> Bool {
            switch (lhs, rhs) {
            case (.text(let lText), .text(let rText)):
                return lText == rText
            case (.image(let lURL), .image(let rURL)):
                return lURL == rURL
            case (.file(let lURL, let lName), .file(let rURL, let rName)):
                return lURL == rURL && lName == rName
            case (.system(let lText), .system(let rText)):
                return lText == rText
            default:
                return false
            }
        }
    }
    
    // 实现 Equatable
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id &&
               lhs.sender == rhs.sender &&
               lhs.content == lhs.content &&
               lhs.timestamp == rhs.timestamp &&
               lhs.status == rhs.status
    }
    
    // Computed property for preview/list display
    var previewText: String {
        switch content {
        case .text(let text): return text
        case .image: return "📸 Photo"
        case .file(_, let filename): return "📎 \(filename)"
        case .system(let text): return text
        }
    }
}



// MARK: - Member Model
struct Member: Identifiable, Hashable {
    let id: UUID
    let name: String
    let avatar: String
    let role: MemberRole
    
    enum MemberRole {
        case owner
        case admin
        case member
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Member, rhs: Member) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Announcement Model
struct Announcement {
    let id: UUID
    let content: String
    let timestamp: Date
    let link: URL?
    let creator: Member
}

// MARK: - Factory Extensions
extension ChatRoom {
    static func createIndividual(
        name: String,
        avatar: String,
        members: [Member]
    ) -> ChatRoom {
        ChatRoom(
            name: name,
            type: .individual,
            avatar: avatar,
            members: members
        )
    }
    
    static func createGroup(
        name: String,
        avatar: String,
        members: [Member],
        announcement: Announcement? = nil
    ) -> ChatRoom {
        ChatRoom(
            name: name,
            type: .group,
            avatar: avatar,
            members: members,
            announcement: announcement
        )
    }
}

// MARK: - Sample Data
extension ChatRoom {
    static var samples: [ChatRoom] = {
        let member1 = Member(id: UUID(), name: "Alice", avatar: "sample1", role: .owner)
        let member2 = Member(id: UUID(), name: "Bob", avatar: "sample2", role: .member)
        
        return [
            createIndividual(
                name: "Tina Aalto",
                avatar: "sample2",
                members: [member1, member2]
            ),
            createGroup(
                name: "Study Group",
                avatar: "sample2",
                members: [member1, member2]
            )
        ]
    }()
}
