//
//  Recipe.swift
//  food
//
//  Created by toyousoft on 2024/11/03.
//

import Foundation

// MARK: - Models
struct RecommendedRecipe: Identifiable, Hashable {
    let id = UUID()
    let imageName: String
    let title: String
    let imageNames: [String]
    let authorName: String
    let location: String
    let tags: [String]
    let participantsCount: Int
    let postedTime: String
    let distance: Int
    let isLiked: Bool
    
    // Additional properties
    let avatarImage: String
    let remainingDays: String
    let publishDate: String
    let joinedCount: String
    let content: String
}

// MARK: - Preview Helpers
extension RecommendedRecipe {
    static var sampleData: [RecommendedRecipe] = [
        RecommendedRecipe(
            imageName: "sample1",
            title: "有一起打球的的吗",
            imageNames: ["sample1", "reco_2", "reco_3"],
            authorName: "劉子源",
            location: "東京都 葛飾区 立石",
            tags: ["娱乐", "运动", "篮球"],
            participantsCount: 99,
            postedTime: "10 mins",
            distance: 300,
            isLiked: false,
            // 新增属性的值
            avatarImage: "sample2",
            remainingDays: "3 days",
            publishDate: "2024-10-01",
            joinedCount: "75＋",
            content: "今天早上我有个计划，就是去入管局办理一些手续。最近一直忙着工作，所以这件事拖了好久。想着今天正好有空，赶紧去处理一下。"
        ),
        RecommendedRecipe(
            imageName: "sample1",
            title: "有一起打球的的吗",
            imageNames: ["sample1", "reco_2", "reco_3"],
            authorName: "劉子源",
            location: "東京都 葛飾区 立石",
            tags: ["娱乐", "运动", "篮球"],
            participantsCount: 99,
            postedTime: "10 mins",
            distance: 300,
            isLiked: false,
            // 新增属性的值
            avatarImage: "sample2",
            remainingDays: "3 days",
            publishDate: "2024-10-01",
            joinedCount: "75＋",
            content: "今天早上我有个计划，就是去入管局办理一些手续。最近一直忙着工作，所以这件事拖了好久。想着今天正好有空，赶紧去处理一下。"
        ),
        RecommendedRecipe(
            imageName: "sample1",
            title: "有一起打球的的吗",
            imageNames: ["sample1", "reco_2", "reco_3", "sample1", "sample1"],
            authorName: "劉子源",
            location: "東京都 葛飾区 立石",
            tags: ["娱乐", "运动", "篮球"],
            participantsCount: 99,
            postedTime: "10 mins",
            distance: 300,
            isLiked: false,
            // 新增属性的值
            avatarImage: "sample2",
            remainingDays: "3 days",
            publishDate: "2024-10-01",
            joinedCount: "75＋",
            content: "今天早上我有个计划，就是去入管局办理一些手续。最近一直忙着工作，所以这件事拖了好久。想着今天正好有空，赶紧去处理一下。"
        ),
        RecommendedRecipe(
            imageName: "sample1",
            title: "有一起打球的的吗",
            imageNames: ["sample2"],
            authorName: "劉子源",
            location: "東京都 葛飾区 立石",
            tags: ["娱乐", "运动", "篮球"],
            participantsCount: 99,
            postedTime: "10 mins",
            distance: 300,
            isLiked: false,
            // 新增属性的值
            avatarImage: "sample2",
            remainingDays: "3 days",
            publishDate: "2024-10-01",
            joinedCount: "75＋",
            content: "今天早上我有个计划，就是去入管局办理一些手续。最近一直忙着工作，所以这件事拖了好久。想着今天正好有空，赶紧去处理一下。"
        )
    ]
}
