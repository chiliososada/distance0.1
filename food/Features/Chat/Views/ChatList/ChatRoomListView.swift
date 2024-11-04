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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ListHeaderView(viewModel: viewModel)
                TabSelectionView(selectedTab: $viewModel.selectedTab)
                ChatTabView(viewModel: viewModel)
            }
            .navigationBarHidden(true)
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .navigationDestination(isPresented: $viewModel.isNavigating) {
                if let selectedRoom = viewModel.selectedChatRoom {
                    ChatDetailView(chatRoom: selectedRoom)
                }
            }
        }
    }
}

// MARK: - Supporting Views
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

struct ChatTabView: View {
    @ObservedObject var viewModel: ChatRoomListViewModel
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            ChatListView(
                chatRooms: viewModel.filteredRooms,
                selectedChatRoom: $viewModel.selectedChatRoom,
                isNavigating: $viewModel.isNavigating
            )
            .tag(0)
            
            ChatListView(
                chatRooms: viewModel.filteredRooms,
                selectedChatRoom: $viewModel.selectedChatRoom,
                isNavigating: $viewModel.isNavigating
            )
            .tag(1)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}

// MARK: - Preview
struct ChatRoomListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChatRoomListView()
                .previewDisplayName("Light Mode")
            
            ChatRoomListView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
