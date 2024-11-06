//  HomeTabContentViewModel.swift
//  food
//
//  Created by toyousoft on 2024/11/05.

import SwiftUI
import Combine

final class HomeTabContentViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var posts: [LocationPost] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    // MARK: - Dependencies
    private let postManager = LocationPostManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        setupBindings()
        Task {
            await loadInitialData()
        }
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // 监听过滤后的帖子变化
        postManager.$filteredPosts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                self?.posts = posts
            }
            .store(in: &cancellables)
        
        // 监听加载状态
        postManager.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        // 监听错误状态
        postManager.$error
            .receive(on: DispatchQueue.main)
            .assign(to: \.error, on: self)
            .store(in: &cancellables)
    }
    
    @MainActor
    private func loadInitialData() async {
        do {
            // 初始加载时不应用任何过滤
            try await postManager.fetchPosts()
        } catch {
            self.error = error
            print("Failed to load initial data: \(error)")
        }
    }
    
    // MARK: - Public Methods
    @MainActor
    func refresh() async {
        do {
            try await postManager.fetchPosts()
        } catch {
            self.error = error
            print("Refresh failed: \(error)")
        }
    }
    
    @MainActor
    func search(text: String) async {
        do {
            try await postManager.fetchPosts(searchText: text)
        } catch {
            self.error = error
            print("Search failed: \(error)")
        }
    }
    
    func clearError() {
        error = nil
    }
}

//// MARK: - Preview Helper
//extension HomeTabContentViewModel {
//    static var preview: HomeTabContentViewModel {
//        let viewModel = HomeTabContentViewModel()
//        viewModel.posts = [
//            LocationPost(
//                title: "有一起打球的的吗",
//                content: "今天早上我有个计划，就是去入管局办理一些手续。",
//                authorName: "劉子源",
//                locationName: "東京都 葛飾区 立石",
//                latitude: 35.681236,
//                longitude: 139.767125,
//                imageNames: ["sample1", "reco_2", "reco_3"],
//                avatarImage: "sample2",
//                tags: ["娱乐", "运动", "篮球"],
//                participantsCount: 99,
//                postedTime: "10 mins",
//                remainingDays: "3 days",
//                publishDate: "2024-10-01",
//                joinedCount: "75＋"
//            )
//        ]
//        return viewModel
//    }
//}
