//
//  ReviewItem.swift
//  food
//
//  Created by toyousoft on 2024/11/03.
//

import Foundation

// MARK: - Review Item Model
struct ReviewItem: Identifiable {
    let id = UUID()
    let name: String
    let date: String
    let location: String
    let review: String
    let participants: Int
    let tags: [String]
    let timeElapsed: String
    let distance: String
    let title: String
    let showAvatar: Bool
    let avatarImage: String
    
    // MARK: - Sample Data
    static let sampleData: [ReviewItem] = [
        ReviewItem(
            name: "John Doe",
            date: "2024-10-03",
            location: "東京都 葛飾区 立石",
            review: "This is a sample review text. It discusses the product or service in detail and gives insights about its pros and cons.",
            participants: 99,
            tags: ["活动", "社交", "健身"],
            timeElapsed: "3 days",
            distance: "300m",
            title: "有一起去吃中华料理的吗？",
            showAvatar: true,
            avatarImage: "sample1"
        ),
        ReviewItem(
            name: "Jane Smith",
            date: "2024-10-04",
            location: "東京都 新宿区",
            review: "Another sample review showing different content and location.",
            participants: 75,
            tags: ["美食", "社交", "探店"],
            timeElapsed: "1 day",
            distance: "500m",
            title: "新开的拉面店好吃吗？",
            showAvatar: true,
            avatarImage: "sample2"
        )
    ]
}

// MARK: - Review Item List Section Model
struct ReviewSection {
    let publishedContent: [ReviewItem]
    let savedContent: [ReviewItem]
    
    static let sample = ReviewSection(
        publishedContent: [ReviewItem.sampleData[0]],
        savedContent: [ReviewItem.sampleData[1]]
    )
}
