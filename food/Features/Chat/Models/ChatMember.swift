//
//  Member.swift
//  food
//
//  Created by toyousoft on 2024/11/03.
//
// Models/ChatMember.swift

import Foundation

// MARK: - Chat Member Model
struct ChatMember: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let imageName: String
    
    // MARK: - Sample Data
    static var sampleMembers: [ChatMember] = [
        ChatMember(name: "Isabellaa s da s d", imageName: "sample1"),
        ChatMember(name: "Martin", imageName: "sample2"),
        ChatMember(name: "Shirley", imageName: "sample1"),
        ChatMember(name: "David", imageName: "sample1"),
        ChatMember(name: "Matilde", imageName: "sample1"),
        ChatMember(name: "Eli", imageName: "sample1")
    ]
}
