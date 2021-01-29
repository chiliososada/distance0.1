//
//  ChatListView.swift
//  food
//
//  Created by toyousoft on 2024/10/09.
//
import SwiftUI

struct ChatListView: View {
    let chatRooms: [ChatRoom]
    @Binding var selectedChatRoom: ChatRoom? // Bind the selected chat room for navigation
    @Binding var isNavigating: Bool // Control when navigation should happen
    
    var body: some View {
        List {
            ForEach(chatRooms) { chatRoom in
                // Use a Button instead of NavigationLink to customize the behavior
                Button(action: {
                            selectedChatRoom = chatRoom
                            isNavigating = true // Trigger navigation after the animation completes
                        
                }) {
                    VStack(spacing: 0) {
                        // Chat room information part
                        ChatRoomRow(chatRoom: chatRoom)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 3)
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                    }
                }
                .buttonStyle(PlainButtonStyle()) // Remove arrow and tap effect
                .listRowSeparator(.hidden) // Hide separators
                .listRowInsets(EdgeInsets()) // Remove extra padding
            }
        }
        .listStyle(PlainListStyle())
        .background(Color(.white)) // Set list background color
    }
}
