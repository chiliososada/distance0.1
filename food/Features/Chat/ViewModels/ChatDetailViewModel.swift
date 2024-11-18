import Foundation
import SwiftUI

final class ChatDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var messages: [Message] = []
    @Published var newMessage = ""
    @Published var isAnnouncementVisible = true
    @Published var showMemberList = false
    @Published var viewState: ViewState = .loading
    
    // MARK: - Properties
    let chatRoom: ChatRoom
    var currentMember: Member  // 当前用户
    
    // MARK: - View State
    enum ViewState {
        case loading
        case loaded
        case error(String)
    }
    
    // MARK: - Initialization
    init(chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
        // TODO: 从用户系统获取当前用户信息
        self.currentMember = Member(
            id: UUID(),
            name: "Me",
            avatar: "sample1",
            role: .member
        )
        loadInitialMessages()
    }
    
    // MARK: - Public Methods
    func sendMessage() {
        guard !newMessage.isEmpty else { return }
        
        let newMsg = Message(
            id: UUID(),
            sender: currentMember,
            content: .text(newMessage),
            timestamp: Date(),
            status: .sending
        )
        
        withAnimation {
            messages.append(newMsg)
        }
        
        // 模拟发送消息
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let index = self.messages.firstIndex(where: { $0.id == newMsg.id }) {
                withAnimation {
                    // 更新消息状态为已发送
                    var updatedMsg = newMsg
                    updatedMsg = Message(
                        id: newMsg.id,
                        sender: newMsg.sender,
                        content: newMsg.content,
                        timestamp: newMsg.timestamp,
                        status: .sent
                    )
                    self.messages[index] = updatedMsg
                }
            }
        }
        
        newMessage = ""
        dismissKeyboard()
    }
    
    func toggleAnnouncement() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isAnnouncementVisible.toggle()
        }
    }
    
    func showSettings() {
        showMemberList = true
    }
    
    // MARK: - Private Methods
    private func loadInitialMessages() {
        viewState = .loading
        
        // 模拟网络请求延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let alice = Member(
                id: UUID(),
                name: "Alice",
                avatar: "sample1",
                role: .member
            )
            
            let bob = Member(
                id: UUID(),
                name: "Bob",
                avatar: "sample2",
                role: .member
            )
            
            self.messages = [
                Message(
                    id: UUID(),
                    sender: alice,
                    content: .text("Lets goooooo @AJPicard913, I'm buying mine now"),
                    timestamp: Date().addingTimeInterval(-3600),
                    status: .read
                ),
                Message(
                    id: UUID(),
                    sender: bob,
                    content: .text("Count me in! Can't wait!"),
                    timestamp: Date().addingTimeInterval(-1800),
                    status: .read
                ),
                Message(
                    id: UUID(),
                    sender: self.currentMember,
                    content: .text("Great! See you all there!"),
                    timestamp: Date(),
                    status: .sent
                )
            ]
            
            self.viewState = .loaded
        }
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
    func showMoreOptions() {
           // 实现更多选项的展示逻辑
           print("Showing more options menu")
       }
       
    func showEmojiPicker() {
           // 实现表情选择器的展示逻辑
           print("Showing emoji picker")
    }
}

// MARK: - Preview Helper
extension ChatDetailViewModel {
    static func preview(chatRoom: ChatRoom) -> ChatDetailViewModel {
        let viewModel = ChatDetailViewModel(chatRoom: chatRoom)
        // 预览数据会通过 loadInitialMessages 自动加载
        return viewModel
    }
}
