import SwiftUI

// MARK: - Constants
private enum Layout {
    static let avatarSize: CGFloat = 50
    static let groupIconSize: CGFloat = 16
    static let groupIconOffset: CGFloat = 15
    static let verticalPadding: CGFloat = 10
    static let horizontalPadding: CGFloat = 16
    static let messageSpacing: CGFloat = 5
    static let borderWidth: CGFloat = 1
    static let unreadDotSize: CGFloat = 8
}

// MARK: - Main View
struct ChatRoomRow: View {
    let chatRoom: ChatRoom
    
    var body: some View {
        HStack {
            AvatarView(
                imageName: chatRoom.avatar,
                isGroup: chatRoom.type == .group
            )
            
            MessageContent(
                name: chatRoom.name,
                lastMessage: chatRoom.lastMessage
            )
            
            Spacer()
            
            // 右侧时间和未读消息组
            VStack(alignment: .trailing, spacing: 4) {
                // 时间显示
                TimeView(timestamp: chatRoom.lastMessage?.timestamp)
                
                // 未读消息计数
                if chatRoom.unreadCount > 0 {
                    UnreadCountBadge(count: chatRoom.unreadCount)
                }
            }
            .frame(width: 60) // 固定宽度保持对齐
        }
        .padding(.vertical, Layout.verticalPadding)
        .padding(.horizontal, Layout.horizontalPadding)
        .background(Color.white)
    }
}
// 未读消息计数徽章
struct UnreadCountBadge: View {
    let count: Int
    
    var body: some View {
        Text("\(count)")
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white)
            .frame(minWidth: 18, minHeight: 18) // 修复语法错误
            .background(Color.red)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.white, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}
// MARK: - Supporting Views
private struct AvatarView: View {
    let imageName: String
    let isGroup: Bool
    
    var body: some View {
        ZStack {
            // Avatar Image
            Image(imageName)
                .resizable()
                .frame(width: Layout.avatarSize, height: Layout.avatarSize)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.5), lineWidth: Layout.borderWidth)
                )
            
            // Group Chat Indicator
            if isGroup {
                GroupChatIcon()
            }
        }
    }
}

private struct GroupChatIcon: View {
    var body: some View {
        Image(systemName: "person.3.fill")
            .resizable()
            .frame(width: Layout.groupIconSize, height: Layout.groupIconSize)
            .background(Color.white)
            .clipShape(Circle())
            .foregroundColor(.blue)
            .offset(x: Layout.groupIconOffset, y: Layout.groupIconOffset)
    }
}

private struct MessageContent: View {
    let name: String
    let lastMessage: Message?
    
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.messageSpacing) {
            Text(name)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(messagePreview)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(1)
        }
    }
    
    private var messagePreview: String {
        lastMessage?.previewText ?? "No messages yet"
    }
}

struct TimeView: View {
    let timestamp: Date?
    
    var body: some View {
        Text(formattedTime)
            .font(.caption)
            .foregroundColor(.gray)
    }
    
    private var formattedTime: String {
        guard let timestamp = timestamp else { return "" }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        
        // 如果是今天的消息，显示具体时间
        if Calendar.current.isDateInToday(timestamp) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            return timeFormatter.string(from: timestamp)
        }
        
        // 其他情况显示相对时间
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
// MARK: - Preview Provider
struct ChatRoomRow_Previews: PreviewProvider {
    static let previewMember = Member(
        id: UUID(),
        name: "Alice",
        avatar: "sample1",
        role: .member
    )
    
    static var previews: some View {
        Group {
            // Regular Chat Preview
            ChatRoomRow(
                chatRoom: ChatRoom(
                    name: "Tina Aalto",
                    type: .individual,
                    avatar: "sample2",
                    lastMessage: Message(
                        id: UUID(),
                        sender: previewMember,
                        content: .text("Will probably arrive at 9. See ya!"),
                        timestamp: Date().addingTimeInterval(-1800),
                        status: .sent
                    ),
                    members: [previewMember]
                )
            )
            .previewDisplayName("Individual Chat")
            
            // Group Chat Preview
            ChatRoomRow(
                chatRoom: ChatRoom(
                    name: "Team Meeting",
                    type: .group,
                    avatar: "sample2",
                    lastMessage: Message(
                        id: UUID(),
                        sender: previewMember,
                        content: .text("Let's discuss this tomorrow"),
                        timestamp: Date().addingTimeInterval(-3600),
                        status: .read
                    ),
                    members: [previewMember]
                )
            )
            .previewDisplayName("Group Chat")
            
            // No Message Preview
            ChatRoomRow(
                chatRoom: ChatRoom(
                    name: "New Chat",
                    type: .individual,
                    avatar: "sample1",
                    members: [previewMember]
                )
            )
            .previewDisplayName("No Messages")
        }
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.gray.opacity(0.2))
    }
}
