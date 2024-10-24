//
//  ChatRoomRow.swift
//  food
//
//  Created by toyousoft on 2024/10/09.
//

import SwiftUI
struct ChatRoomRow: View {
    let chatRoom: ChatRoom
    
    var body: some View {
        HStack {
            ZStack {
                // Chat room avatar
                Image(chatRoom.avatar)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
                
                // Group chat icon
                if chatRoom.isGroupChat {
                    Image(systemName: "person.3.fill")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .background(Color.white) // Prevent icon and avatar color overlap
                        .clipShape(Circle())
                        .foregroundColor(.blue)
                        .offset(x: 15, y: 15) // Position icon in bottom right corner
                }
            }
            
            VStack(alignment: .leading, spacing: 5) {
                // Chat room name
                Text(chatRoom.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // Last message
                Text(chatRoom.lastMessage)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Last message time
            Text(chatRoom.time)
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(Color.white)
    }
}
struct ChatRoomRow_Previews: PreviewProvider {
    static var previews: some View {
        // 示例数据
        let exampleChatRoom = ChatRoom(
            name: "Tina Aalto", lastMessage: "Will probably arrive at 9. See ya!", time: "20:30", avatar: "sample2", isGroupChat: false
        )
        
        // 使用示例数据渲染 ChatRoomRow
        ChatRoomRow(chatRoom: exampleChatRoom)
            .previewLayout(.sizeThatFits) // 调整预览布局
            .padding() // 添加一些间距，便于查看
            .background(Color.gray.opacity(0.2)) // 背景方便观察效果
    }
}
