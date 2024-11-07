import Foundation
import SwiftUI

final class ChatSettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isTopChat: Bool
    @Published var viewState: ViewState = .loading
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var confirmAction: (() -> Void)?
    
    // MARK: - Properties
    let chatRoom: ChatRoom
    var members: [Member] { chatRoom.members }
    var announcement: Announcement? { chatRoom.announcement }
    
    // MARK: - View State
    enum ViewState {
        case loading
        case loaded
        case error(String)
    }
    
    // MARK: - Actions
    enum Action {
        case clearChat
        case deleteChat
        case shareChat
        case showQRCode
        case updateAnnouncement(String)
    }
    
    // MARK: - Initialization
    init(chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
        self.isTopChat = chatRoom.isTopChat
        loadChatRoomData()
    }
    
    // MARK: - Public Methods
    func handleAction(_ action: Action) {
        switch action {
        case .clearChat:
            showConfirmation(
                message: "确定要清空聊天记录吗？",
                action: clearChatHistory
            )
            
        case .deleteChat:
            showConfirmation(
                message: "确定要删除该聊天室吗？",
                action: deleteChat
            )
            
        case .shareChat:
            shareChat()
            
        case .showQRCode:
            generateQRCode()
            
        case .updateAnnouncement(let newContent):
            updateAnnouncement(content: newContent)
        }
    }
    
    func toggleTopChat() {
        isTopChat.toggle()
        updateChatRoomSettings()
    }
    
    func getMemberRole(_ member: Member) -> String {
        switch member.role {
        case .owner:
            return "群主"
        case .admin:
            return "管理员"
        case .member:
            return "成员"
        }
    }
    
    // MARK: - Private Methods
    private func loadChatRoomData() {
        viewState = .loading
        
        // 模拟网络请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 在实际应用中，这里应该从服务器刷新聊天室数据
            self.viewState = .loaded
        }
    }
    
    private func showConfirmation(message: String, action: @escaping () -> Void) {
        alertMessage = message
        confirmAction = action
        showAlert = true
    }
    
    private func updateChatRoomSettings() {
        // 模拟网络请求 - 更新聊天室设置
        // 例如：更新置顶状态
        print("Updating chat room settings: isTopChat = \(isTopChat)")
    }
    
    private func clearChatHistory() {
        // 实现清空聊天记录的逻辑
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("Chat history cleared for room: \(self.chatRoom.id)")
            // 成功后可以显示提示
            self.showAlert = false
        }
    }
    
    private func deleteChat() {
        // 实现删除聊天室的逻辑
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("Chat room deleted: \(self.chatRoom.id)")
            self.showAlert = false
            // 这里应该触发返回上一页面的逻辑
        }
    }
    
    private func shareChat() {
        // 实现分享聊天室的逻辑
        let shareText = """
        加入聊天室：\(chatRoom.name)
        成员数：\(members.count)
        """
        print("Sharing chat room: \(shareText)")
    }
    
    private func generateQRCode() {
        // 实现生成二维码的逻辑
        let qrData = "chatroom:\(chatRoom.id)"
        print("Generating QR code with data: \(qrData)")
    }
    
    private func updateAnnouncement(content: String) {
        // 模拟更新公告
        guard chatRoom.type == .group else { return }
        
        viewState = .loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("Announcement updated: \(content)")
            self.viewState = .loaded
        }
    }
}

// MARK: - Preview Helper
extension ChatSettingsViewModel {
    static func preview(chatRoom: ChatRoom) -> ChatSettingsViewModel {
        let viewModel = ChatSettingsViewModel(chatRoom: chatRoom)
        // 预览数据会通过 loadChatRoomData 自动加载
        return viewModel
    }
}
