import SwiftUI

// MARK: - Constants
private enum Layout {
    static let iconSize: CGFloat = 30
    static let cornerRadius: CGFloat = 10
    static let shadowRadius: CGFloat = 3
    static let spacing: CGFloat = 10
    
    static let shadowColor = Color.gray.opacity(0.3)
    static let borderColor = Color.black.opacity(0.5)
}

// MARK: - Main View
struct ChatRoomListView: View {
    @StateObject private var viewModel = ChatRoomListViewModel()
    @EnvironmentObject private var navigationManager: AppNavigationManager
    init() {
        print("ChatRoomListView")
    }
    var body: some View {
            VStack(spacing: 0) {
                ListHeaderView(viewModel: viewModel)
                TabSelectionView(selectedTab: $viewModel.selectedTab)
                ChatTabView(viewModel: viewModel)
            }
            .background(Color.white.ignoresSafeArea())
        }
}

// MARK: - Header Components
struct ListHeaderView: View {
    @ObservedObject var viewModel: ChatRoomListViewModel
    
    var body: some View {
        HStack {
            SearchButton(showSearchBar: $viewModel.showSearchBar)
            
            Spacer()
            
            if viewModel.showSearchBar {
                SearchBar(searchText: $viewModel.searchText)
            } else {
                TitleView()
            }
            
            Spacer()
            
            UnreadBadge(count: viewModel.unreadCount)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.white)
    }
}

struct SearchButton: View {
    @Binding var showSearchBar: Bool
    
    var body: some View {
        Button(action: { withAnimation { showSearchBar.toggle() }}) {
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .foregroundColor(.black)
                .padding(10)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: Layout.shadowColor, radius: Layout.shadowRadius)
        }
    }
}

struct SearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        TextField("Search...", text: $searchText)
            .padding(10)
            .background(Color.white)
            .cornerRadius(Layout.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Layout.cornerRadius)
                    .stroke(Layout.borderColor, lineWidth: 0.5)
            )
            .padding(.horizontal)
    }
}

struct TitleView: View {
    var body: some View {
        Text("Chats")
            .font(.system(size: 22, weight: .medium))
            .foregroundColor(.black)
            .transition(.move(edge: .leading))
    }
}

struct UnreadBadge: View {
    let count: Int
    
    var body: some View {
        ZStack {
            Image(systemName: "ellipsis.bubble")
                .resizable()
                .frame(width: Layout.iconSize, height: Layout.iconSize)
                .opacity(0.8)
                .shadow(radius: 5)
            
            Text("\(count)")
                .font(.caption2)
                .foregroundColor(.white)
                .padding(6)
                .background(Color.red)
                .clipShape(Circle())
                .offset(x: 10, y: -10)
        }
    }
}

// MARK: - Tab Components
struct TabSelectionView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            ChatRoomsTabButton(title: "最近的消息", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            Spacer()
            
            ChatRoomsTabButton(title: "店家推送", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .background(Color.white)
    }
}

struct ChatRoomsTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(title)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(isSelected ? .black : .gray)
                
                Capsule()
                    .fill(isSelected ? Color.black : Color.clear)
                    .frame(height: 2)
            }
        }
    }
}

// MARK: - Chat List Components
struct ChatTabView: View {
    @ObservedObject var viewModel: ChatRoomListViewModel
    @EnvironmentObject private var navigationManager: AppNavigationManager
    
    var body: some View {
        // 移除 TabView,改用基于 selectedTab 的条件渲染
        Group {
            if viewModel.selectedTab == 0 {
                ChatListContent(
                    chatRooms: viewModel.filteredRooms,
                    navigationManager: navigationManager
                )
            } else {
                ChatListContent(
                    chatRooms: viewModel.filteredRooms,
                    navigationManager: navigationManager
                )
            }
        }
        // 可以添加切换动画
        .animation(.easeInOut, value: viewModel.selectedTab)
    }
}

struct ChatListContent: View {
    let chatRooms: [ChatRoom]
    let navigationManager: AppNavigationManager
    @State private var showDeleteAlert = false
    @State private var chatRoomToDelete: ChatRoom?
    
    var body: some View {
        List {
            ForEach(chatRooms) { chatRoom in
                ChatRoomCell(
                    chatRoom: chatRoom,
                    onSelect: {
                        let route = AppRoute.chatDetail(chatRoom: chatRoom)
                        navigationManager.navigate(to: route)
                    }
                )
                .listRowStyle()
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    // 删除按钮
                    Button(role: .destructive) {
                        chatRoomToDelete = chatRoom
                        showDeleteAlert = true
                    } label: {
                        Label("删除", systemImage: "trash")
                    }
                    .tint(.red)
                }
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    // 收藏/取消收藏按钮
                    Button {
                        // 处理收藏/取消收藏操作
                        print("Toggle favorite for chat room: \(chatRoom.id)")
                    } label: {
                        Label(chatRoom.isTopChat ? "取消置顶" : "置顶",
                              systemImage: chatRoom.isTopChat ? "pin.slash" : "pin")
                    }
                    .tint(.orange)
                    
                    // 标记已读/未读按钮
                    Button {
                        // 处理标记已读/未读操作
                        print("Toggle read status for chat room: \(chatRoom.id)")
                    } label: {
                        Label("已读", systemImage: "checkmark.circle")
                    }
                    .tint(.blue)
                }
            }
        }
        .listStyle(PlainListStyle())
        .background(Color.white)
        // 删除确认对话框
        .alert("删除聊天", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                if let chatRoom = chatRoomToDelete {
                    // 处理删除操作
                    print("Deleting chat room: \(chatRoom.id)")
                }
            }
        } message: {
            if let chatRoom = chatRoomToDelete {
                Text("确定要删除与\"\(chatRoom.name)\"的聊天吗？")
            }
        }
    }
}

// MARK: - Cell Components
struct ChatRoomCell: View {
    let chatRoom: ChatRoom
    let onSelect: () -> Void
    @State private var offset: CGFloat = 0
    
    var body: some View {
        Button(action: onSelect) {
            ChatRoomRow(chatRoom: chatRoom)
                .modifier(ChatRoomStyle())
        }
        .buttonStyle(PlainButtonStyle())
        // 添加滑动反馈动画
        .offset(x: offset)
        .animation(.interactiveSpring(), value: offset)
    }
}

// MARK: - View Modifiers
struct ChatRoomStyle: ViewModifier {
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

// MARK: - View Extensions
private extension View {
    func listRowStyle() -> some View {
        self
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
    }
}

// MARK: - Preview Provider
struct ChatRoomListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomListView()
            .environmentObject(AppNavigationManager.shared)
    }
}
