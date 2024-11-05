import SwiftUI

struct ChatListView: View {
    let chatRooms: [ChatRoom]
    @Binding var selectedChatRoom: ChatRoom?
    @Binding var isNavigating: Bool
    @EnvironmentObject private var navigationManager: AppNavigationManager
    
    var body: some View {
        List {
            ForEach(chatRooms) { chatRoom in
                ChatRoomCell(
                    chatRoom: chatRoom,
                    onSelect: {
                        navigationManager.navigate(to: .chatDetail(chatRoom: chatRoom))
                    }
                )
                .listRowStyle()
            }
        }
        .listStyle(PlainListStyle())
        .background(Color.white)
    }
}

// MARK: - Supporting Views
private struct ChatRoomCell: View {
    let chatRoom: ChatRoom
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            ChatRoomRow(chatRoom: chatRoom)
                .modifier(ChatRoomStyle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Modifiers
private struct ChatRoomStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.white)
            .cornerRadius(10)
            .shadow(
                color: .gray.opacity(0.3),
                radius: 3,
                x: 0,
                y: 3
            )
            .padding(.horizontal)
            .padding(.vertical, 5)
    }
}

private extension View {
    func listRowStyle() -> some View {
        self
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
    }
}

// MARK: - Preview
struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView(
            chatRooms: [
                ChatRoom(name: "Test Chat", lastMessage: "Hello", time: "12:00", avatar: "sample1", isGroupChat: false)
            ],
            selectedChatRoom: .constant(nil),
            isNavigating: .constant(false)
        )
        .environmentObject(AppNavigationManager.shared)
    }
}
