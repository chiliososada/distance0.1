import SwiftUI

struct ChatRoom: Identifiable {
    let id = UUID()
    let name: String
    let lastMessage: String
    let time: String
    let avatar: String
    let isGroupChat: Bool // 用于判断是否为群聊
}

struct ChatRoomListView: View {
    // 模拟的聊天室数据
    let chatRooms = [
        ChatRoom(name: "Tina Aalto", lastMessage: "Will probably arrive at 9. See ya!", time: "20:30", avatar: "sample2", isGroupChat: false),
        ChatRoom(name: "Jenny Chan", lastMessage: "It's not that big a deal.", time: "21:20", avatar: "sample2", isGroupChat: false),
        ChatRoom(name: "Jane Cooper", lastMessage: "Does he write an email?", time: "6:18", avatar: "sample2", isGroupChat: false),
        ChatRoom(name: "Study Group", lastMessage: "Let's meet at 3 PM tomorrow.", time: "18:00", avatar: "sample2", isGroupChat: true),
        ChatRoom(name: "Family", lastMessage: "Don't forget to bring dessert!", time: "11:09", avatar: "sample2", isGroupChat: true),
        ChatRoom(name: "Work Team", lastMessage: "The report is due today!", time: "10:26", avatar: "sample2", isGroupChat: true),
        ChatRoom(name: "Jacob Jones", lastMessage: "Night night!", time: "2:55", avatar: "sample2", isGroupChat: false),
        ChatRoom(name: "Running Club", lastMessage: "Who's in for the 5k?", time: "14:02", avatar: "sample2", isGroupChat: true),
        ChatRoom(name: "Ronald Richards", lastMessage: "See you tomorrow at the meeting.", time: "14:45", avatar: "sample2", isGroupChat: false),
        ChatRoom(name: "Game Night", lastMessage: "Board games on Friday!", time: "17:30", avatar: "sample2", isGroupChat: true)
    ]
//    @EnvironmentObject var tabBarViewModel: TabBarViewModel
    @State private var selectedTab = 0 // Track the selected tab
    @State private var showSearchBar = false // State variable to toggle search bar
    @State private var searchText = ""       // State variable for search text
    @State private var selectedChatRoom: ChatRoom? // State to track the selected chat room
    @State private var isNavigating = false // Controls whether navigation should happen
   
 
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        withAnimation {
                            showSearchBar.toggle() // Toggle search bar visibility
                        }
                    }) {
                        Image(systemName: "magnifyingglass") // Search icon
                            .font(.title2)
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 3)
                    }
                    Spacer()
                    
                    if showSearchBar {
                        // Search Bar visible when toggled
                        HStack {
                            TextField("Search...", text: $searchText)
                                .padding(10)
                                .background(Color(.white))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 0.5)  // 黑色外边框
                                )
                                .padding(.horizontal)
                        }

                    } else {
                        // Title "Chats" when search bar is not visible
                        Text("Chats")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.black)
                            .transition(.move(edge: .leading)) // Animation for title
                    }
                    
                    Spacer()
                    
                    ZStack {
                        // 消息气泡图标
                        Image(systemName: "ellipsis.bubble")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .opacity(0.8)
                            .shadow(radius: 5)
                        
                        // 未读消息数的显示
                        Text("3")  // 这里显示未读消息数，你可以将"3"替换为你的动态数据
                            .font(.caption2)  // 设置字体大小
                            .foregroundColor(.white)  // 字体颜色
                            .padding(6)  // 内边距，确保有圆形背景
                            .background(Color.red)  // 红色背景，表示未读数
                            .clipShape(Circle())  // 裁剪为圆形
                            .offset(x: 10, y: -10)  // 调整位置，使其在右上角显示
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color.white)
                
                // Top Tab Control
                HStack {
                    Button(action: {
                        selectedTab = 0
                    }) {
                        VStack {
                            Text("最近的消息") // My Posts
                                .fontWeight(selectedTab == 0 ? .bold : .regular)
                                .foregroundColor(selectedTab == 0 ? .black : .gray)
                            if selectedTab == 0 {
                                Capsule()
                                    .fill(Color.black)
                                    .frame(height: 2)
                            } else {
                                Capsule()
                                    .fill(Color.clear)
                                    .frame(height: 2)
                            }
                        }
                    }
                    Spacer()
                    
                    Button(action: {
                        selectedTab = 1
                    }) {
                        VStack {
                            Text("店家推送") // Store Promotions
                                .fontWeight(selectedTab == 1 ? .bold : .regular)
                                .foregroundColor(selectedTab == 1 ? .black : .gray)
                            if selectedTab == 1 {
                                Capsule()
                                    .fill(Color.black)
                                    .frame(height: 2)
                            } else {
                                Capsule()
                                    .fill(Color.clear)
                                    .frame(height: 2)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .background(Color.white)

                // TabView for swiping between sections
                TabView(selection: $selectedTab) {
                    ChatListView(chatRooms: chatRooms.filter { !$0.isGroupChat }, selectedChatRoom: $selectedChatRoom, isNavigating: $isNavigating)
                        .tag(0)
                    
                    ChatListView(chatRooms: chatRooms.filter { $0.isGroupChat }, selectedChatRoom: $selectedChatRoom, isNavigating: $isNavigating)
                        .tag(1)
                    
                    ChatListView(chatRooms: chatRooms.filter { $0.isGroupChat }, selectedChatRoom: $selectedChatRoom, isNavigating: $isNavigating)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hide the dots indicator
            }
            .navigationBarHidden(true) // Hide default navigation bar
            .background(Color(.white).edgesIgnoringSafeArea(.all))
            
            // Programmatically trigger navigation to ChatDetailView
            .navigationDestination(isPresented: $isNavigating) {
                if let selectedChatRoom = selectedChatRoom {
                    ChatDetailView(chatRoom: selectedChatRoom)
                        
                        
                }
            }
        }
    }
}







struct ChatRoomListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomListView().environmentObject(TabBarManager())
    }
}
