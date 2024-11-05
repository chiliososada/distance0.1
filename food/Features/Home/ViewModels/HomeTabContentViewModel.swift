//
//  HomeTabContentViewModel.swift
//  food
//
//  Created by toyousoft on 2024/11/05.
//

import  SwiftUI

// MARK: - HomeTabContentViewModel
final class HomeTabContentViewModel: ObservableObject {
    @Published var recommendedRecipes: [RecommendedRecipe] = []
    
    init() {
        loadInitialData()
    }
    
    private func loadInitialData() {
        // 模拟数据加载
        recommendedRecipes = [
            RecommendedRecipe(
                imageName: "sample1",
                title: "有一起打球的的吗",
                imageNames: ["sample1", "reco_2", "reco_3", "sample1", "reco_3"],
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
                imageNames: ["4_3"],
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
                imageNames: ["4_5"],
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
                title: "一起去看电影吧",
                imageNames: ["1_1"],
                authorName: "王小明",
                location: "東京都 新宿区",
                tags: ["娱乐", "电影", "社交"],
                participantsCount: 56,
                postedTime: "20 mins",
                distance: 500,
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
                imageNames: ["4_3","4_5"],
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
                title: "4_3有一起打球的的吗",
                imageNames: ["4_3","4_5","1_1"],
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
                title: "4-3有一起打球的的1吗",
                imageNames: ["4_3","4_3","4_3"],
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
                title: "4-5有一起打球的的吗",
                imageNames: ["4_5","4_5","1_1","4_5"],
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
                imageNames: ["4_5","4_3"],
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
                title: "一起去看电影吧",
                imageNames: ["1_1","1_1","1_1"],
                authorName: "王小明",
                location: "東京都 新宿区",
                tags: ["娱乐", "电影", "社交"],
                participantsCount: 56,
                postedTime: "20 mins",
                distance: 500,
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
                title: "音乐节拼车",
                imageNames: ["sample1", "sample1", "sample1", "sample1"],
                authorName: "李华",
                location: "東京都 渋谷区",
                tags: ["音乐", "节日", "拼车"],
                participantsCount: 150,
                postedTime: "30 mins",
                distance: 700,
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
                title: "周末一起骑行",
                imageNames: ["reco_3", "sample1"],
                authorName: "张三",
                location: "東京都 世田谷区",
                tags: ["运动", "骑行", "健身"],
                participantsCount: 25,
                postedTime: "1 hour",
                distance: 1000,
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
}
