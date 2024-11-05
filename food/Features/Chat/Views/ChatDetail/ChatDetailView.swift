import SwiftUI

// MARK: - View Model


// MARK: - Constants
private enum Layout {
    static let iconSize: CGFloat = 16
    static let buttonPadding: CGFloat = 10
    static let cornerRadius: CGFloat = 16
    static let shadowRadius: CGFloat = 3
    
    static let colors = ColorScheme()
    
    struct ColorScheme {
        let primary = Color.blue
        let secondary = Color.black
        let border = Color.black.opacity(0.2)
        let shadow = Color.gray.opacity(0.2)
    }
}

// MARK: - Main View
struct ChatDetailView: View {
    @StateObject private var viewModel: ChatDetailViewModel
    @EnvironmentObject var navigationManager: AppNavigationManager
    @EnvironmentObject var tabBarManager: TabBarManager
    
    init(chatRoom: ChatRoom) {
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
                currentUser: viewModel.currentUser
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
//        .tabBarVisibility(tabBarManager)
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

struct MessagesSection: View {
    let messages: [ChatMessage]
    let currentUser: String
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(messages) { message in
                    MessageView(
                        message: message,
                        isCurrentUser: message.userName == currentUser
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
        HStack(spacing: 10) {
            MediaButton()
            MessageTextField(text: $viewModel.newMessage)
            SendButton(action: viewModel.sendMessage)
        }
        .padding(.horizontal)
        .padding(.bottom, 1)
    }
}

struct MediaButton: View {
    var body: some View {
        Button(action: {}) {
            Image(systemName: "camera.fill")
                .font(.system(size: Layout.iconSize))
                .foregroundColor(.white)
                .padding(Layout.buttonPadding)
                .background(Layout.colors.primary)
                .clipShape(Circle())
                .shadow(radius: Layout.shadowRadius)
        }
    }
}

struct MessageTextField: View {
    @Binding var text: String
    
    var body: some View {
        TextField("Start typing...", text: $text)
            .padding(Layout.buttonPadding)
            .background(Color.white)
            .cornerRadius(Layout.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Layout.cornerRadius)
                    .stroke(Layout.colors.border, lineWidth: 1)
            )
            .foregroundColor(.black)
            .shadow(radius: 1)
    }
}

struct SendButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "paperplane.fill")
                .font(.system(size: Layout.iconSize))
                .foregroundColor(.white)
                .padding(Layout.buttonPadding)
                .background(Layout.colors.secondary)
                .clipShape(Circle())
                .shadow(radius: Layout.shadowRadius)
        }
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
                    lastMessage: "This is the last message",
                    time: "14:30",
                    avatar: "sampleAvatar",
                    isGroupChat: true
                )
            )
            .environmentObject(TabBarManager())
        }
    }
}
