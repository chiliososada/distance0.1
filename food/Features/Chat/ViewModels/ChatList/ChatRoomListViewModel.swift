import Foundation
import SwiftUI

final class ChatRoomListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedTab = 0
    @Published var showSearchBar = false
    @Published var searchText = ""
    @Published var selectedChatRoom: ChatRoom?
    @Published var isNavigating = false
    @Published var unreadCount = 3
    
    // MARK: - Chat Room Data
    @Published private(set) var chatRooms: [ChatRoom] = []
    
    // MARK: - Current User
    private let currentMember = Member(
        id: UUID(),
        name: "Me",
        avatar: "sample1",
        role: .member
    )
    
    // MARK: - Computed Properties
    var filteredRooms: [ChatRoom] {
        let rooms = chatRooms.filter { room in
            selectedTab == 0 ? room.type == .individual : room.type == .group
        }
        
        if searchText.isEmpty {
            return rooms
        }
        
        return rooms.filter { room in
            room.name.localizedCaseInsensitiveContains(searchText) ||
            (room.lastMessage?.previewText ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Initialization
    init() {
        loadChatRooms()
    }
    
    // MARK: - Public Methods
    func toggleSearchBar() {
        withAnimation {
            showSearchBar.toggle()
        }
    }
    
    func selectChatRoom(_ chatRoom: ChatRoom) {
        withAnimation {
            selectedChatRoom = chatRoom
            isNavigating = true
        }
    }
    
    // MARK: - Private Methods
    private func loadChatRooms() {
        // 创建一些示例成员
        let tina = Member(id: UUID(), name: "Tina Aalto", avatar: "sample2", role: .member)
        let jenny = Member(id: UUID(), name: "Jenny Chan", avatar: "sample2", role: .member)
        let alice = Member(id: UUID(), name: "Alice", avatar: "sample1", role: .member)
        let bob = Member(id: UUID(), name: "Bob", avatar: "sample2", role: .owner)
        
        // 创建一些示例消息
        let tinaMessage = Message(
            id: UUID(),
            sender: tina,
            content: .text("Will probably arrive at 9. See ya!"),
            timestamp: Date().addingTimeInterval(-1800),
            status: .read
        )
        
        let jennyMessage = Message(
            id: UUID(),
            sender: jenny,
            content: .text("It's not that big a deal."),
            timestamp: Date().addingTimeInterval(-3600),
            status: .delivered
        )
        
        let groupMessage = Message(
            id: UUID(),
            sender: alice,
            content: .text("Let's meet at 3 PM tomorrow."),
            timestamp: Date().addingTimeInterval(-7200),
            status: .sent
        )
        
        // 创建示例公告
        let announcement = Announcement(
            id: UUID(),
            content: "Welcome to our study group!",
            timestamp: Date(),
            link: URL(string: "https://example.com"),
            creator: bob
        )
        
        // 创建聊天室
        chatRooms = [
            // 个人聊天
            ChatRoom(
                name: "Tina Aalto",
                type: .individual,
                avatar: "sample2",
                lastMessage: tinaMessage,
                members: [currentMember, tina]
            ),
            
            ChatRoom(
                name: "Jenny Chan",
                type: .individual,
                avatar: "sample2",
                lastMessage: jennyMessage,
                members: [currentMember, jenny]
            ),
            
            // 群聊
            ChatRoom(
                name: "Study Group",
                type: .group,
                avatar: "sample2",
                lastMessage: groupMessage,
                members: [currentMember, alice, bob, jenny],
                announcement: announcement
            )
        ]
    }
}

// MARK: - Preview Helper
extension ChatRoomListViewModel {
    static var preview: ChatRoomListViewModel {
        let viewModel = ChatRoomListViewModel()
        return viewModel
    }
}
