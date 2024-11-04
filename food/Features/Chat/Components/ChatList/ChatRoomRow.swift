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
}

// MARK: - Main View
struct ChatRoomRow: View {
    let chatRoom: ChatRoom
    
    var body: some View {
        HStack {
            AvatarView(
                imageName: chatRoom.avatar,
                isGroupChat: chatRoom.isGroupChat
            )
            
            MessageContent(
                name: chatRoom.name,
                message: chatRoom.lastMessage
            )
            
            Spacer()
            
            TimeView(time: chatRoom.time)
        }
        .padding(.vertical, Layout.verticalPadding)
        .padding(.horizontal, Layout.horizontalPadding)
        .background(Color.white)
    }
}

// MARK: - Supporting Views
private struct AvatarView: View {
    let imageName: String
    let isGroupChat: Bool
    
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
            if isGroupChat {
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
    let message: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.messageSpacing) {
            Text(name)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(1)
        }
    }
}

private struct TimeView: View {
    let time: String
    
    var body: some View {
        Text(time)
            .font(.footnote)
            .foregroundColor(.gray)
    }
}

// MARK: - Preview Provider
struct ChatRoomRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Regular Chat Preview
            ChatRoomRow(
                chatRoom: ChatRoom(
                    name: "Tina Aalto",
                    lastMessage: "Will probably arrive at 9. See ya!",
                    time: "20:30",
                    avatar: "sample2",
                    isGroupChat: false
                )
            )
            .previewDisplayName("Individual Chat")
            
            // Group Chat Preview
            ChatRoomRow(
                chatRoom: ChatRoom(
                    name: "Team Meeting",
                    lastMessage: "Let's discuss this tomorrow",
                    time: "15:45",
                    avatar: "sample2",
                    isGroupChat: true
                )
            )
            .previewDisplayName("Group Chat")
        }
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.gray.opacity(0.2))
    }
}
