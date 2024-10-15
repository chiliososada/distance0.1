import SwiftUI

struct ChatDetailView: View {
    let chatRoom: ChatRoom
    @Environment(\.presentationMode) var presentationMode
    @State private var showMemberList = false // 控制弹出成员列表

    @EnvironmentObject var tabBarManager: TabBarManager // Add this line to access TabBarManager
 
    
    
    
    // 模拟消息数据
    @State private var messages = [
        Message(id: 1, userName: "Alice", text: "Lets goooooo @AJPicard913, I'm buying mine now", avatar: "sample1"),
        Message(id: 2, userName: "Bob", text: "Just got my pairs! Had to buy two of them! These are so fireeeeeee!!!!", avatar: "sample2"),
        Message(id: 3, userName: "Me", text: "Who else is doing stuff like this?! @AJPicard913 this is dope man just purchased my pair.", avatar: "sample1"),
        Message(id: 4, userName: "Alice", text: "Lets goooooo @AJPicard913, I'm buying mine now", avatar: "sample1"),
        Message(id: 5, userName: "Alice", text: "Lets goooooo @AJPicard913, I'm buying mine now", avatar: "sample1"),
        Message(id: 6, userName: "Alice", text: "Lets goooooo @AJPicard913, I'm buying mine now", avatar: "sample1"),
        Message(id: 7, userName: "Alice", text: "Lets goooooo @AJPicard913, I'm buying mine now", avatar: "sample1"),
        Message(id: 8, userName: "Alice", text: "Lets goooooo @AJPicard913, I'm buying mine now", avatar: "sample1")
    ]
    @State private var newMessage = ""
    @State var isAnnouncementVisible = true // 控制公告的显示状态
    var currentUser = "Me" // 当前用户的名字
    
    
    
    
    

    var body: some View {
        VStack(spacing: 1) {
            // 顶部公告视图
            if isAnnouncementVisible {
                AnnouncementView()
                    .transition(.move(edge: .top)) // 顶部移动过渡动画
                    .padding(.top, 6)
                    .padding(.bottom, 6)
            }

            // 控制收起/展开公告按钮
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isAnnouncementVisible.toggle() // 切换公告显示状态
                }
            }) {
                Text(isAnnouncementVisible ? "收起公告" : "展开公告")
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .padding(.bottom, 4)
            }
            
            // 消息列表
            ScrollView {
                VStack(spacing: 1) {
                    ForEach(messages) { message in
                        MessageView(message: message, isCurrentUser: message.userName == currentUser)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 4)
            
            // 输入框和操作按钮部分
            HStack(spacing: 10) {
                // 图片按钮
                Button(action: {
                    // 添加图片按钮操作
                }) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.blue)
                        .clipShape(Circle()) // 圆形按钮
                        .shadow(radius: 3)
                }
                
                // 输入框
                TextField("Start typing...", text: $newMessage)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(0.2), lineWidth: 1) // 边框颜色稍浅
                    )
                    .foregroundColor(.black)
                    .shadow(radius: 1)
                
                // 发送按钮
                Button(action: {
                    if !newMessage.isEmpty {
                        let newMsg = Message(id: messages.count + 1, userName: currentUser, text: newMessage, avatar: "sample1")
                        messages.append(newMsg)
                        newMessage = ""
                        // 键盘收起
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.black)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 1)
        }
        .navigationTitle(chatRoom.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.black)
                        .padding(6)
                        .background(Color.white)
                        .cornerRadius(6)
                        .shadow(radius: 2)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showMemberList = true // 打开成员列表
                }) {
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.black)
                }
            }
        }
        .onAppear {
            tabBarManager.isViewTabBarHidden = true // Hide TabBar when HomeView appears
        }
        .onDisappear {
            tabBarManager.isViewTabBarHidden = false // Show TabBar when HomeView disappears
        }
        .sheet(isPresented: $showMemberList) {
            ZStack {
                BlurView()  // 模糊背景

                VStack {
                    // 主内容视图
                    ChatSettingsView()
                        .padding()
                        .background(Color.white)
                        .cornerRadius(30, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
                        .shadow(radius: 10)
                        .padding()
                }
                .background(Color.clear)
            }
        }
    }
}

// Add Preview
struct ChatDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let mockChatRoom = ChatRoom(
            name: "Sample Chat",
            lastMessage: "This is the last message",
            time: "14:30",
            avatar: "sampleAvatar",
            isGroupChat: true
        )
        
        NavigationView {
            ChatDetailView(chatRoom: mockChatRoom)
                .environmentObject(TabBarManager()) // Injecting TabBarManager instance for preview
        }
    }
}
