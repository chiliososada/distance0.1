//
//  ChatRoom.swift
//  food
//
//  Created by toyousoft on 2024/11/03.
//

import Foundation

// MARK: - Chat Room Model
struct ChatRoom: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let lastMessage: String
    let time: String
    let avatar: String
    let isGroupChat: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: ChatRoom, rhs: ChatRoom) -> Bool {
           lhs.id == rhs.id
    }
    // MARK: - Initialization
     init(
         name: String,
         lastMessage: String = "新的对话",  // 提供默认值
         time: String = "现在",            // 提供默认值
         avatar: String,
         isGroupChat: Bool
     ) {
         self.name = name
         self.lastMessage = lastMessage
         self.time = time
         self.avatar = avatar
         self.isGroupChat = isGroupChat
     }

    // MARK: - Sample Data
    static var sampleData: [ChatRoom] = [
        ChatRoom(
            name: "Tina Aalto",
            lastMessage: "Will probably arrive at 9. See ya!",
            time: "20:30",
            avatar: "sample2",
            isGroupChat: false
        ),
        ChatRoom(
            name: "Study Group",
            lastMessage: "Let's meet at 3 PM tomorrow.",
            time: "18:00",
            avatar: "sample2",
            isGroupChat: true
        ),
        ChatRoom(
            name: "Family",
            lastMessage: "Don't forget to bring dessert!",
            time: "11:09",
            avatar: "sample2",
            isGroupChat: true
        ),
        ChatRoom(
            name: "Work Team",
            lastMessage: "The report is due today!",
            time: "10:26",
            avatar: "sample2",
            isGroupChat: true
        ),
        ChatRoom(
            name: "Running Club",
            lastMessage: "Who's in for the 5k?",
            time: "14:02",
            avatar: "sample2",
            isGroupChat: true
        )
    ]
}


