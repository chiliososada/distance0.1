import SwiftUI

// MARK: - View Model


// MARK: - Constants
private enum Layout {
    static let iconSize: CGFloat = 24 // 增大图标尺寸
    static let buttonSize: CGFloat = 32 // 按钮大小
    static let cornerRadius: CGFloat = 20 // 输入框圆角
    
    static let colors = ColorScheme()
    
    struct ColorScheme {
        let primary = Color.blue
        let secondary = Color.black
        let border = Color.black
        let buttonGray = Color.gray.opacity(0.4)
        let textGray = Color.gray.opacity(0.3)
    }
}

// MARK: - Main View
struct ChatDetailView: View {
    private let chatRoom: ChatRoom
    @StateObject private var viewModel: ChatDetailViewModel
    @EnvironmentObject var navigationManager: AppNavigationManager
    @EnvironmentObject var tabBarManager: TabBarManager
    
    // 添加一个静态属性来跟踪当前显示的聊天室ID
    private static var currentChatRoomId: UUID?
    
    init(chatRoom: ChatRoom) {
        // 检查是否已经显示这个聊天室
        if Self.currentChatRoomId == chatRoom.id {
            print("ChatDetailView - Skipping duplicate initialization for room: \(chatRoom.id)")
            self.chatRoom = chatRoom
            // 使用已存在的 ViewModel
            _viewModel = StateObject(wrappedValue: ChatDetailViewModel(chatRoom: chatRoom))
            return
        }
        
        print("ChatDetailView init - Room: \(chatRoom.name), ID: \(chatRoom.id)")
        self.chatRoom = chatRoom
        _viewModel = StateObject(wrappedValue: ChatDetailViewModel(chatRoom: chatRoom))
    }
    
    var body: some View {
        VStack(spacing: 1) {
            AnnouncementSection(
                isVisible: $viewModel.isAnnouncementVisible
            )
            
            MessagesSection(
                messages: viewModel.messages,
                currentMember: viewModel.currentMember
            )
            
            DetailInputSection(viewModel: viewModel)
        }
        .id(chatRoom.id.uuidString)
        .onAppear {
            print("ChatDetailView onAppear - Room: \(chatRoom.name), ID: \(chatRoom.id)")
            Self.currentChatRoomId = chatRoom.id
            tabBarManager.isNavigatingInTab = true
        }
        .onDisappear {
            print("ChatDetailView onDisappear - Room: \(chatRoom.name), ID: \(chatRoom.id)")
            if navigationManager.navigationPath.count == 0 {
                tabBarManager.isNavigatingInTab = false
                Self.currentChatRoomId = nil
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton(action: {
                    Self.currentChatRoomId = nil  // 清除当前ID
                    navigationManager.goBack()
                })
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                SettingsButton(action: {
                    viewModel.showSettings()
                })
            }
            ToolbarItem(placement: .principal) {
                Text(chatRoom.name)
                    .font(.headline)
            }
        }
        .memberListSheet(
            isPresented: $viewModel.showMemberList,
            chatRoom: chatRoom
        )
    }
}
// MARK: - Supporting Views
struct AnnouncementSection: View {
    @Binding var isVisible: Bool
    
    var body: some View {
        VStack {
            if isVisible {
                AnnouncementView()
                    .transition(.move(edge: .top))
                    .padding(.vertical, 6)
            }
            
            ToggleButton(isVisible: $isVisible)
        }
    }
}

struct ToggleButton: View {
    @Binding var isVisible: Bool
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isVisible.toggle()
            }
        } label: {
            Text(isVisible ? "收起公告" : "展开公告")
                .font(.footnote)
                .foregroundColor(.blue)
                .padding(.bottom, 4)
        }
    }
}

// MessagesSection 更新
struct MessagesSection: View {
    let messages: [Message]
    let currentMember: Member
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(messages) { message in
                    MessageView(
                        message: message,
                        isCurrentUser: message.sender.id == currentMember.id
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 4)
    }
}

struct DetailInputSection: View {
    @ObservedObject var viewModel: ChatDetailViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // 主要输入区域
            HStack(alignment: .bottom, spacing: 12) {
                AddButton(
                    action: viewModel.showMoreOptions,
                    isShowingMedia: viewModel.showMediaOptions  
                )
                
                if !viewModel.showMediaOptions {
                    AdaptiveTextEditor(
                        text: $viewModel.newMessage,
                        placeholder: "",
                        isShowingEmoji: $viewModel.isShowingEmoji
                    )
                    
                    Button(action: viewModel.showEmojiPickerView) {
                        Image(systemName: viewModel.isShowingEmoji ? "keyboard" : "face.smiling")
                            .font(.system(size: Layout.iconSize, weight: .light))
                            .foregroundColor(.black)
                            .frame(width: Layout.buttonSize, height: Layout.buttonSize)
                            .clipShape(Circle())
                    }
                    
                    SendButton(
                        action: viewModel.sendMessage,
                        isEnabled: !viewModel.newMessage.isEmpty
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white)
            
            // 底部区域：媒体选项、表情键盘或系统键盘
            if viewModel.showMediaOptions {
                MediaOptionsMenu(
                    isPresented: $viewModel.showMediaOptions,
                    onSelect: viewModel.handleMediaResult
                )
            }
        }
        .background(Color.white)
        .animation(.easeOut(duration: 0.2), value: viewModel.newMessage)
        .animation(.easeOut(duration: 0.2), value: viewModel.showMediaOptions)
    }
}





struct AddButton: View {
    let action: () -> Void
    let isShowingMedia: Bool  // 添加状态属性
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isShowingMedia ? "xmark" : "plus")  // 根据状态切换图标
                .font(.system(size: Layout.iconSize, weight: .light))
                .foregroundColor(.black)
                .frame(width: Layout.buttonSize, height: Layout.buttonSize)
                .clipShape(Circle())
        }
    }
}


struct EmojiButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "face.smiling")
                .font(.system(size: Layout.iconSize, weight: .light))
                .foregroundColor(.black)
                .frame(width: Layout.buttonSize, height: Layout.buttonSize)
            
                .clipShape(Circle())
        }
    }
}


struct SendButton: View {
    let action: () -> Void
    let isEnabled: Bool
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "paperplane.fill")
                .font(.system(size: Layout.iconSize))
                .foregroundColor(.black)
                .frame(width: Layout.buttonSize, height: Layout.buttonSize)
                .clipShape(Circle())
        }
        .disabled(!isEnabled)
    }
}

// MARK: - View Extensions
extension View {
    func navigationBar(
        title: String,
        onBack: @escaping () -> Void,
        onSettings: @escaping () -> Void
    ) -> some View {
        self.navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton(action: onBack)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    SettingsButton(action: onSettings)
                }
            }
    }
    
    func tabBarVisibility(_ manager: TabBarManager) -> some View {
        self.onAppear { manager.isViewTabBarHidden = true }
            .onDisappear { manager.isViewTabBarHidden = false }
    }
    
    func memberListSheet(isPresented: Binding<Bool>, chatRoom: ChatRoom) -> some View {
        self.sheet(isPresented: isPresented) {
            ZStack {
                BlurView()
                VStack {
                    ChatSettingsView(chatRoom: chatRoom)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(30)
                        .shadow(radius: 10)
                        .padding()
                }
                .background(Color.clear)
            }
        }
    }
}

// MARK: - Toolbar Buttons
struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.title3)
                .foregroundColor(.black)
                .padding(6)
                .background(Color.white)
                .cornerRadius(6)
                .shadow(radius: 2)
        }
    }
}

struct SettingsButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "gearshape")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.black)
        }
    }
}

// MARK: - Preview
struct ChatDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {  // 使用 NavigationStack 替代 NavigationView
            ChatDetailView(chatRoom: .preview)  // 直接使用 ChatRoom.preview
                .environmentObject(AppNavigationManager.shared)  // 添加 navigationManager
                .environmentObject(TabBarManager())
        }
    }
}

extension ChatRoom {
    static var preview: ChatRoom {
        ChatRoom(
            name: "Sample Chat",
            type: .group,
            avatar: "sampleAvatar",
            lastMessage: Message(
                id: UUID(),
                sender: Member(
                    id: UUID(),
                    name: "Alice",
                    avatar: "sample1",
                    role: .member
                ),
                content: .text("This is the last message"),
                timestamp: Date(),
                status: .sent
            ),
            members: [
                Member(id: UUID(), name: "Alice", avatar: "sample1", role: .owner),
                Member(id: UUID(), name: "Bob", avatar: "sample2", role: .member)
            ]
        )
    }
}
