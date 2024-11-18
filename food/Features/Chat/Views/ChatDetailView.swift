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
    @StateObject private var viewModel: ChatDetailViewModel
    @EnvironmentObject var navigationManager: AppNavigationManager
    @EnvironmentObject var tabBarManager: TabBarManager
    
    init(chatRoom: ChatRoom) {
        print("chatdeteal view")
        _viewModel = StateObject(wrappedValue: ChatDetailViewModel(chatRoom: chatRoom))
    }
    
    var body: some View {
        VStack(spacing: 1) {
            // 公告区域
            AnnouncementSection(
                isVisible: $viewModel.isAnnouncementVisible
            )
            
            // 消息列表
            MessagesSection(
                messages: viewModel.messages,
                currentMember: viewModel.currentMember
            )
            
            // 输入区域
            DetailInputSection(viewModel: viewModel)
        }
        .onAppear {
            tabBarManager.isNavigatingInTab = true
        }
        .onDisappear {
            // 只有当返回到主页面时才重置状态
            if navigationManager.navigationPath.count == 0 {
                tabBarManager.isNavigatingInTab = false
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton(action: {
                    navigationManager.goBack()
                })
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                SettingsButton(action: {
                    viewModel.showSettings()
                })
            }
            ToolbarItem(placement: .principal) {
                Text(viewModel.chatRoom.name)
                    .font(.headline)
            }
        }
        .memberListSheet(
            isPresented: $viewModel.showMemberList,
            chatRoom: viewModel.chatRoom
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
        HStack(alignment: .bottom, spacing: 12) { // 修改对齐方式为底部对齐
            AddButton(action: viewModel.showMoreOptions)
            
            AdaptiveTextEditor(
                text: $viewModel.newMessage,
                placeholder: ""
            ) 
            
            EmojiButton(action: viewModel.showEmojiPicker)
            
            SendButton(
                action: viewModel.sendMessage,
                isEnabled: !viewModel.newMessage.isEmpty
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white)
        .animation(.easeOut(duration: 0.2), value: viewModel.newMessage)
    }
}




struct AddButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
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
        NavigationView {
            ChatDetailView(
                chatRoom: ChatRoom(
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
                        Member(
                            id: UUID(),
                            name: "Alice",
                            avatar: "sample1",
                            role: .owner
                        ),
                        Member(
                            id: UUID(),
                            name: "Bob",
                            avatar: "sample2",
                            role: .member
                        )
                    ]
                )
            )
            .environmentObject(TabBarManager())
        }
    }
}
