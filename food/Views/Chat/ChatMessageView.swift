import SwiftUI

// MARK: - Models
struct Message: Identifiable, Equatable {
    let id: Int
    let userName: String
    let text: String
    let avatar: String
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
}

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
    
    var body: some View {
        HStack(spacing: Layout.avatarSpacing) {
            if isCurrentUser {
                Spacer()
                messageContent
                UserAvatar(imageName: message.avatar)
            } else {
                UserAvatar(imageName: message.avatar)
                messageContent
                Spacer()
            }
        }
        .padding(.vertical, Layout.verticalPadding)
    }
    
    private var messageContent: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading,
               spacing: Layout.messageSpacing) {
            UserNameLabel(name: message.userName)
            MessageBubble(text: message.text, isCurrentUser: isCurrentUser)
        }
    }
}

// MARK: - Supporting Views
struct UserAvatar: View {
    let imageName: String
    
    var body: some View {
        Image(imageName)
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
    let text: String
    let isCurrentUser: Bool
    
    var body: some View {
        Text(text)
            .padding(Layout.bubblePadding)
            .background(
                isCurrentUser ? Layout.currentUserBubbleColor : Layout.otherUserBubbleColor
            )
            .clipShape(BubbleShape(isCurrentUser: isCurrentUser))
    }
}

// MARK: - Previews
struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Current User Message
            MessageView(
                message: Message(
                    id: 1,
                    userName: "Me",
                    text: "This is my message that might be very long and need to wrap to multiple lines!",
                    avatar: "sample1"
                ),
                isCurrentUser: true
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Current User")
            
            // Other User Message
            MessageView(
                message: Message(
                    id: 2,
                    userName: "Alice",
                    text: "Hi there! I'm Alice and this is also a long message to test wrapping.",
                    avatar: "sample2"
                ),
                isCurrentUser: false
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Other User")
            
            // Dark Mode Preview
            MessageView(
                message: Message(
                    id: 3,
                    userName: "Bob",
                    text: "Testing dark mode appearance",
                    avatar: "sample1"
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
