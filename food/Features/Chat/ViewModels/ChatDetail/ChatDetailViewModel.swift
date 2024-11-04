//
//  ChatDetailViewModel.swift
//  food
//
//  Created by toyousoft on 2024/11/04.
//

// ViewModels/ChatDetail/ChatDetailViewModel.swift

import Foundation
import SwiftUI

final class ChatDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var messages: [ChatMessage] = []
    @Published var newMessage = ""
    @Published var isAnnouncementVisible = true
    @Published var showMemberList = false
    @Published var viewState: ViewState = .loading
    
    // MARK: - Properties
    let chatRoom: ChatRoom
    let currentUser: String = "Me"  // 之后可以从用户系统获取
    
    // MARK: - View State
    enum ViewState {
        case loading
        case loaded
        case error(String)
    }
    
    // MARK: - Initialization
    init(chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
        loadInitialMessages()
    }
    
    // MARK: - Public Methods
    func sendMessage() {
        guard !newMessage.isEmpty else { return }
        
        let newMsg = ChatMessage(
            id: messages.count + 1,
            userName: currentUser,
            text: newMessage,
            avatar: "sample1"
        )
        
        withAnimation {
            messages.append(newMsg)
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
            self.messages = [
                ChatMessage(
                    id: 1,
                    userName: "Alice",
                    text: "Lets goooooo @AJPicard913, I'm buying mine now",
                    avatar: "sample1"
                ),
                // 添加更多示例消息
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
}

// MARK: - Preview Helper
extension ChatDetailViewModel {
    static func preview(chatRoom: ChatRoom) -> ChatDetailViewModel {
        let viewModel = ChatDetailViewModel(chatRoom: chatRoom)
        // 添加预览数据
        return viewModel
    }
}
