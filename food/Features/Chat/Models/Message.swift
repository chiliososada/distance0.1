//
//  Message.swift
//  food
//
//  Created by toyousoft on 2024/11/03.
//


import Foundation

// MARK: - Message Model
struct Message: Identifiable, Equatable {
    let id: Int
    let userName: String
    let text: String
    let avatar: String
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Sample Data
    static var sampleMessages: [Message] = [
        Message(
            id: 1,
            userName: "Alice",
            text: "Lets goooooo @AJPicard913, I'm buying mine now",
            avatar: "sample1"
        ),
        Message(
            id: 2,
            userName: "Bob",
            text: "Count me in! Can't wait!",
            avatar: "sample2"
        )
    ]
}


