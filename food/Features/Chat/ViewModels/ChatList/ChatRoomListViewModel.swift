//
//  ChatRoomListViewModel.swift
//  food
//
//  Created by toyousoft on 2024/11/04.
//

// ViewModels/ChatList/ChatRoomListViewModel.swift

import Foundation
import SwiftUI

final class ChatRoomListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedTab = 0
    @Published var showSearchBar = false
    @Published var searchText = ""
    @Published var selectedChatRoom: ChatRoom?
    @Published var isNavigating = false
    @Published var unreadCount = 3
    
    // MARK: - Chat Room Data
    @Published private(set) var chatRooms: [ChatRoom] = []
    
    // MARK: - Computed Properties
    var filteredRooms: [ChatRoom] {
        let rooms = chatRooms.filter { room in
            selectedTab == 0 ? !room.isGroupChat : room.isGroupChat
        }
        
        if searchText.isEmpty {
            return rooms
        }
        
        return rooms.filter { room in
            room.name.localizedCaseInsensitiveContains(searchText) ||
            room.lastMessage.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Initialization
    init() {
        loadChatRooms()
    }
    
    // MARK: - Public Methods
    func toggleSearchBar() {
        withAnimation {
            showSearchBar.toggle()
        }
    }
    
    func selectChatRoom(_ chatRoom: ChatRoom) {
        withAnimation {
            selectedChatRoom = chatRoom
            isNavigating = true
        }
    }
    
    // MARK: - Private Methods
    private func loadChatRooms() {
        // 网络请求
        chatRooms = [
            ChatRoom(name: "Tina Aalto", lastMessage: "Will probably arrive at 9. See ya!", time: "20:30", avatar: "sample2", isGroupChat: false),
            ChatRoom(name: "Jenny Chan", lastMessage: "It's not that big a deal.", time: "21:20", avatar: "sample2", isGroupChat: false),
            ChatRoom(name: "Study Group", lastMessage: "Let's meet at 3 PM tomorrow.", time: "18:00", avatar: "sample2", isGroupChat: true)
            
        ]
    }
}

// MARK: - Preview Helper
extension ChatRoomListViewModel {
    static var preview: ChatRoomListViewModel {
        let viewModel = ChatRoomListViewModel()
   
        return viewModel
    }
}
