import SwiftUI

// MARK: - Constants
private enum Layout {
    static let avatarSize: CGFloat = 40
    static let bubbleCornerRadius: CGFloat = 15
    static let bubblePadding: CGFloat = 12
    static let avatarSpacing: CGFloat = 3
    static let messageSpacing: CGFloat = 4
    static let verticalPadding: CGFloat = 5
    
    static let currentUserBubbleColor = Color.blue.opacity(0.4)
    static let otherUserBubbleColor = Color(.systemGray6)
    static let userNameColor = Color.gray
    static let statusColor = Color.gray.opacity(0.6)
}

// MARK: - Bubble Shape
struct BubbleShape: Shape {
    let isCurrentUser: Bool
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let cornerSize = CGSize(width: Layout.bubbleCornerRadius,
                                  height: Layout.bubbleCornerRadius)
            path.addRoundedRect(
                in: CGRect(x: rect.minX, y: rect.minY,
                          width: rect.width, height: rect.height),
                cornerSize: cornerSize
            )
        }
    }
}

// MARK: - Message View
struct MessageView: View {
    let message: Message
    let isCurrentUser: Bool
    @State private var showTime = false
    
    var body: some View {
        HStack(spacing: Layout.avatarSpacing) {
            if isCurrentUser {
                Spacer()
                messageContent
                UserAvatar(member: message.sender)
            } else {
                UserAvatar(member: message.sender)
                messageContent
                Spacer()
            }
        }
        .padding(.vertical, Layout.verticalPadding)
    }
    
    private var messageContent: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading,
               spacing: Layout.messageSpacing) {
            UserNameLabel(name: message.sender.name)
            
            // 消息气泡和时间组合
            ZStack(alignment: isCurrentUser ? .topTrailing : .topLeading) {
                MessageBubble(message: message, isCurrentUser: isCurrentUser)
                    .onTapGesture {
                        withAnimation {
                            showTime.toggle()
                        }
                    }
                
                if showTime {
                    // 时间标签
                    Text(formatMessageTime(message.timestamp))
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                        )
                        .offset(y: -20)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            if isCurrentUser {
                MessageStatus(status: message.status)
            }
        }
    }
    
    private func formatMessageTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views
struct UserAvatar: View {
    let member: Member
    
    var body: some View {
        Image(member.avatar)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: Layout.avatarSize, height: Layout.avatarSize)
            .clipShape(Circle())
    }
}

struct UserNameLabel: View {
    let name: String
    
    var body: some View {
        Text(name)
            .font(.footnote)
            .foregroundColor(Layout.userNameColor)
    }
}

struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        Group {
            switch message.content {
            case .text(let text):
                Text(text)
            case .image:
                Text("📸 Photo")
                    .italic()
            case .file(_, let filename):
                Text("📎 \(filename)")
                    .italic()
            case .system(let text):
                Text(text)
                    .italic()
                    .foregroundColor(.gray)
            }
        }
        .padding(Layout.bubblePadding)
        .background(
            isCurrentUser ? Layout.currentUserBubbleColor : Layout.otherUserBubbleColor
        )
        .clipShape(BubbleShape(isCurrentUser: isCurrentUser))
    }
}

struct MessageStatus: View {
    let status: Message.MessageStatus
    
    var body: some View {
        Text(statusText)
            .font(.caption2)
            .foregroundColor(Layout.statusColor)
    }
    
    private var statusText: String {
        switch status {
        case .sending:
            return "发送中..."
        case .sent:
            return "已发送"
        case .delivered:
            return "已送达"
        case .read:
            return "已读"
        case .failed:
            return "发送失败"
        }
    }
}

// MARK: - Previews
struct MessageView_Previews: PreviewProvider {
    static let currentMember = Member(
        id: UUID(),
        name: "Me",
        avatar: "sample1",
        role: .member
    )
    
    static let otherMember = Member(
        id: UUID(),
        name: "Alice",
        avatar: "sample2",
        role: .member
    )
    
    static var previews: some View {
        Group {
            // Current User Message
            MessageView(
                message: Message(
                    id: UUID(),
                    sender: currentMember,
                    content: .text("This is my message that might be very long and need to wrap to multiple lines!"),
                    timestamp: Date(),
                    status: .sent
                ),
                isCurrentUser: true
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Current User")
            
            // Other User Message
            MessageView(
                message: Message(
                    id: UUID(),
                    sender: otherMember,
                    content: .text("Hi there! I'm Alice and this is also a long message to test wrapping."),
                    timestamp: Date(),
                    status: .read
                ),
                isCurrentUser: false
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Other User")
            
            // System Message
            MessageView(
                message: Message(
                    id: UUID(),
                    sender: otherMember,
                    content: .system("Alice joined the group"),
                    timestamp: Date(),
                    status: .delivered
                ),
                isCurrentUser: false
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("System Message")
            
            // Image Message
            MessageView(
                message: Message(
                    id: UUID(),
                    sender: currentMember,
                    content: .image(URL(string: "https://example.com/image.jpg")!),
                    timestamp: Date(),
                    status: .sending
                ),
                isCurrentUser: true
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Image Message")
            
            // Dark Mode Preview
            MessageView(
                message: Message(
                    id: UUID(),
                    sender: currentMember,
                    content: .text("Testing dark mode appearance"),
                    timestamp: Date(),
                    status: .failed
                ),
                isCurrentUser: true
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
