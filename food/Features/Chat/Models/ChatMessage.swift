//
//  Message.swift
//  food
//
//  Created by toyousoft on 2024/11/03.
//




import Foundation

// MARK: - Chat Message Model
struct ChatMessage: Identifiable, Equatable {
    let id: Int
    let userName: String
    let text: String
    let avatar: String
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Sample Data
    static var sampleMessages: [ChatMessage] = [
        ChatMessage(
            id: 1,
            userName: "Alice",
            text: "Lets goooooo @AJPicard913, I'm buying mine now",
            avatar: "sample1"
        ),
        ChatMessage(
            id: 2,
            userName: "Bob",
            text: "Count me in! Can't wait!",
            avatar: "sample2"
        )
    ]
}

