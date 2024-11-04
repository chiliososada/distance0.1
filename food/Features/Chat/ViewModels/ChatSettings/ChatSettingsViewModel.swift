//
//  Untitled.swift
//  food
//
//  Created by toyousoft on 2024/11/04.
//

// ViewModels/ChatSettings/ChatSettingsViewModel.swift

import Foundation
import SwiftUI

final class ChatSettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isTopChat = false
    @Published var members: [ChatMember] = []
    @Published var viewState: ViewState = .loading
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    // MARK: - Properties
    let chatRoom: ChatRoom
    
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
    }
    
    // MARK: - Initialization
    init(chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
        loadMembers()
    }
    
    // MARK: - Public Methods
    func handleAction(_ action: Action) {
        switch action {
        case .clearChat:
            showConfirmation(message: "确定要清空聊天记录吗？") {
                self.clearChatHistory()
            }
        case .deleteChat:
            showConfirmation(message: "确定要删除该聊天室吗？") {
                self.deleteChat()
            }
        case .shareChat:
            shareChat()
        case .showQRCode:
            generateQRCode()
        }
    }
    
    func toggleTopChat() {
        isTopChat.toggle()
        // 实现置顶聊天的逻辑
    }
    
    // MARK: - Private Methods
    private func loadMembers() {
        viewState = .loading
        
        // 模拟网络请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.members = [
                ChatMember(name: "Isabellaa s da s d", imageName: "sample1"),
                ChatMember(name: "Martin", imageName: "sample2"),
                // 添加更多成员
            ]
            self.viewState = .loaded
        }
    }
    
    private func showConfirmation(message: String, action: @escaping () -> Void) {
        alertMessage = message
        showAlert = true
        // 实现确认对话框逻辑
    }
    
    private func clearChatHistory() {
        // 实现清空聊天记录的逻辑
    }
    
    private func deleteChat() {
        // 实现删除聊天室的逻辑
    }
    
    private func shareChat() {
        // 实现分享聊天室的逻辑
    }
    
    private func generateQRCode() {
        // 实现生成二维码的逻辑
    }
}

// MARK: - Preview Helper
extension ChatSettingsViewModel {
    static func preview(chatRoom: ChatRoom) -> ChatSettingsViewModel {
        let viewModel = ChatSettingsViewModel(chatRoom: chatRoom)
        // 添加预览数据
        return viewModel
    }
}
