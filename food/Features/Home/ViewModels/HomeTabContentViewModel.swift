import SwiftUI
import Combine

@MainActor
final class HomeTabContentViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var posts: [LocationPost] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published var searchText = ""
    
    // MARK: - Private Properties
    private let locationService: PostLocationService
    private var cancellables = Set<AnyCancellable>()
    private let debounceInterval: TimeInterval = 0.3
    
    // MARK: - Initialization
    init(locationService: PostLocationService? = nil) {
        self.locationService = locationService ?? PostLocationService.shared
        setupBindings()
    }

    // MARK: - Public Methods
    func loadInitialPosts() async {
        await fetchPosts()
    }
    
    func refreshPosts() async {
        await fetchPosts()
    }
    
    func filterPosts(by category: String? = nil, tags: Set<String>? = nil) async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // 获取所有帖子
            try await locationService.fetchPosts()
            var filteredPosts = locationService.posts
            
            // 应用分类过滤
            if let category = category {
                filteredPosts = filteredPosts.filter { $0.tags.contains(category) }
            }
            
            // 应用标签过滤
            if let tags = tags, !tags.isEmpty {
                filteredPosts = filteredPosts.filter { post in
                    !Set(post.tags).intersection(tags).isEmpty
                }
            }
            
            // 应用搜索过滤
            if !searchText.isEmpty {
                filteredPosts = filteredPosts.filter { post in
                    post.title?.localizedCaseInsensitiveContains(searchText) == true ||
                    post.content.localizedCaseInsensitiveContains(searchText) ||
                    post.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
                }
            }
            
            self.posts = filteredPosts
            
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // 搜索文本变化时自动触发过滤
        $searchText
            .debounce(for: .seconds(debounceInterval), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.filterPosts()
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchPosts() async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await locationService.fetchPosts()
            self.posts = locationService.posts
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Post Management Methods
    func deletePost(_ post: LocationPost) async {
        // TODO: Implement post deletion through PostLocationService
        // This would require adding deletion functionality to PostLocationService
    }
    
    func updatePost(_ post: LocationPost) async {
        // TODO: Implement post updating through PostLocationService
        // This would require adding update functionality to PostLocationService
    }
    
    func createPost(_ post: LocationPost) async {
        // TODO: Implement post creation through PostLocationService
        // This would require adding creation functionality to PostLocationService
    }
    
    // MARK: - Helper Methods
    func clearError() {
        error = nil
    }
    
    func reset() {
        posts = []
        error = nil
        searchText = ""
    }
}

#if DEBUG
extension HomeTabContentViewModel {
    static var preview: HomeTabContentViewModel {
        let viewModel = HomeTabContentViewModel()
        // 可以在这里设置一些预览用的模拟数据
        viewModel.posts = [/* 一些示例数据 */]
        return viewModel
    }
}
#endif
