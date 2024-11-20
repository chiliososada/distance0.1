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
    init() {
        print("HomeTabContentViewModel initialized")
        self.locationService = PostLocationService.shared
        setupBindings()
        
        // 初始化时加载数据
        Task {
            await loadInitialPosts()
        }
    }
    
    // MARK: - Public Methods
    func loadInitialPosts() async {
        print("HomeTabContentViewModel: Loading initial posts")
        await fetchPosts()
    }
    
    func refreshPosts() async {
        print("HomeTabContentViewModel: Refreshing posts")
        await fetchPosts()
    }
    
    func filterPosts(by category: String? = nil, tags: Set<String>? = nil) async {
        guard !isLoading else { return }
        
        print("HomeTabContentViewModel: Filtering posts - category: \(category ?? "none"), tags: \(tags?.joined(separator: ", ") ?? "none")")
        
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
            
            print("HomeTabContentViewModel: Filtered posts count: \(filteredPosts.count)")
            self.posts = filteredPosts
            
        } catch {
            print("HomeTabContentViewModel: Error filtering posts - \(error.localizedDescription)")
            self.error = error
        }
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // 搜索文本变化时自动触发过滤
        $searchText
            .debounce(for: .seconds(debounceInterval), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                print("HomeTabContentViewModel: Search text changed - \(searchText)")
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
            print("HomeTabContentViewModel: Fetched \(posts.count) posts")
        } catch {
            print("HomeTabContentViewModel: Error fetching posts - \(error.localizedDescription)")
            self.error = error
        }
    }
    
    // MARK: - Post Management Methods
    func deletePost(_ post: LocationPost) async {
        print("HomeTabContentViewModel: Attempting to delete post - \(post.id)")
        // TODO: Implement post deletion through PostLocationService
        // This would require adding deletion functionality to PostLocationService
    }
    
    func updatePost(_ post: LocationPost) async {
        print("HomeTabContentViewModel: Attempting to update post - \(post.id)")
        // TODO: Implement post updating through PostLocationService
        // This would require adding update functionality to PostLocationService
    }
    
    func createPost(_ post: LocationPost) async {
        print("HomeTabContentViewModel: Attempting to create new post")
        // TODO: Implement post creation through PostLocationService
        // This would require adding creation functionality to PostLocationService
    }
    
    // MARK: - Helper Methods
    func clearError() {
        error = nil
        print("HomeTabContentViewModel: Cleared error state")
    }
    
    func reset() {
        posts = []
        error = nil
        searchText = ""
        print("HomeTabContentViewModel: Reset view model state")
    }
    
    // MARK: - Cleanup
    deinit {
        print("HomeTabContentViewModel deinitialized")
        cancellables.removeAll()
    }
}

#if DEBUG
extension HomeTabContentViewModel {
    static var preview: HomeTabContentViewModel {
        let viewModel = HomeTabContentViewModel()
        // 可以在这里设置一些预览用的模拟数据
        return viewModel
    }
}
#endif
