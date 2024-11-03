//
//  Member.swift
//  food
//
//  Created by toyousoft on 2024/11/03.
//
import Foundation
// MARK: - Chat Member Model
struct Member: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let imageName: String
    
    // MARK: - Sample Data
    static var sampleMembers: [Member] = [
        Member(name: "Isabellaa s da s d", imageName: "sample1"),
        Member(name: "Martin", imageName: "sample2"),
        Member(name: "Shirley", imageName: "sample1"),
        Member(name: "David", imageName: "sample1"),
        Member(name: "Matilde", imageName: "sample1"),
        Member(name: "Eli", imageName: "sample1")
    ]
}
