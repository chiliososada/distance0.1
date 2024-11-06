import SwiftUI
import MapKit

// MARK: - LocationPost
class LocationPost: NSObject, MKAnnotation, Identifiable {
    // MARK: - Essential Properties
    let id: String
    private let _title: String
    let content: String
    let authorName: String
    let locationName: String
    let coordinate: CLLocationCoordinate2D // 直接作为存储属性，满足 MKAnnotation 要求
    let imageNames: [String]
    let avatarImage: String
    let tags: [String]
    let participantsCount: Int
    let postedTime: String
    let remainingDays: String
    let publishDate: String
    let joinedCount: String
    let isSponsored: Bool
    let sponsored: Bool
        // 使用计算属性包装私有存储属性
        private var _cachedDistance: Double?
        var cachedDistance: Double? {
            get { _cachedDistance }
            set { _cachedDistance = newValue }
        }
    
    
  
    var isLiked: Bool
    
    // MARK: - Computed Properties
    var thumbnailImage: String { imageNames.first ?? "" }
    
    // MKAnnotation protocol - title 和 subtitle 是可选实现的
    var title: String? { _title }
    var subtitle: String? { locationName }
    
    var formattedDistance: String {
        guard let distance = _cachedDistance else { return "距离未知" }
        if distance < 1000 {
            return "距离我 \(Int(distance))m"
        } else {
            let kilometers = Double(round(distance / 100) / 10)
            return "距离我 \(kilometers)km"
        }
    }
    
    // MARK: - NSObject Overrides
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(id)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? LocationPost else { return false }
        return self.id == other.id
    }
    
    // MARK: - Initialization
    init(id: String = UUID().uuidString,
         title: String,
         content: String,
         authorName: String,
         locationName: String,
         latitude: Double,
         longitude: Double,
         imageNames: [String],
         avatarImage: String,
         tags: [String],
         participantsCount: Int,
         postedTime: String,
         remainingDays: String,
         publishDate: String,
         joinedCount: String,
         isSponsored: Bool = false,
         
         isLiked: Bool = false,
         cachedDistance: Double? = nil,
         sponsored: Bool = false) {
        
        self.id = id
        self._title = title
        self.content = content
        self.authorName = authorName
        self.locationName = locationName
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.imageNames = imageNames
        self.avatarImage = avatarImage
        self.tags = tags
        self.participantsCount = participantsCount
        self.postedTime = postedTime
        self.remainingDays = remainingDays
        self.publishDate = publishDate
        self.joinedCount = joinedCount
        self.isSponsored = isSponsored
        self.isLiked = isLiked
        self._cachedDistance = cachedDistance
        self.sponsored = sponsored
        
        super.init()
    }
}

// MARK: - Distance Calculation
extension LocationPost {
    func updateDistance(from coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let postLocation = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
        self._cachedDistance = postLocation.distance(from: location)
    }
    
    func isWithinDistance(_ threshold: Double, from coordinate: CLLocationCoordinate2D) -> Bool {
        if _cachedDistance == nil {
            updateDistance(from: coordinate)
        }
        return _cachedDistance ?? .infinity <= threshold
    }
}
// MARK: - Shared Posts Manager
class LocationPostManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var posts: [LocationPost] = []
    @Published private(set) var filteredPosts: [LocationPost] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    // MARK: - Error Types
    enum PostError: LocalizedError {
        case invalidRegion
        case fetchFailed
        case filterFailed
        
        var errorDescription: String? {
            switch self {
            case .invalidRegion: return "无效的地理区域"
            case .fetchFailed: return "获取数据失败"
            case .filterFailed: return "筛选数据失败"
            }
        }
    }
    
    // MARK: - Singleton
    static let shared = LocationPostManager()
    private init() {
        loadInitialData()
    }
    
    // MARK: - Public Methods
    @MainActor
       func fetchPosts(in region: MKCoordinateRegion? = nil, searchText: String = "") async throws {
           isLoading = true
           error = nil
           
           defer {
               isLoading = false
           }
           
           do {
               // 模拟网络请求延迟
               try await Task.sleep(nanoseconds: 1_000_000_000)
               
               // 应用过滤器
               let filtered = try await filterPosts(posts,
                                                 region: region,
                                                 searchText: searchText)
               
               // 更新状态
               filteredPosts = filtered
               
           } catch {
               self.error = error
               throw error
           }
       }
    
    // MARK: - Private Methods
    private func filterPosts(_ posts: [LocationPost],
                           region: MKCoordinateRegion?,
                           searchText: String) async throws -> [LocationPost] {
        var filtered = posts
        
        // 应用地理位置过滤
        if let region = region {
            filtered = filtered.filter { post in
                isPost(post, inRegion: region)
            }
        }
        
        // 应用搜索文本过滤
        if !searchText.isEmpty {
            filtered = filtered.filter { post in
                matchesSearchCriteria(post, searchText: searchText)
            }
        }
        
        return filtered
    }
    
    private func isPost(_ post: LocationPost, inRegion region: MKCoordinateRegion) -> Bool {
        let coordinate = post.coordinate
        let latDelta = region.span.latitudeDelta / 2.0
        let lonDelta = region.span.longitudeDelta / 2.0
        
        return coordinate.latitude >= region.center.latitude - latDelta &&
               coordinate.latitude <= region.center.latitude + latDelta &&
               coordinate.longitude >= region.center.longitude - lonDelta &&
               coordinate.longitude <= region.center.longitude + lonDelta
    }
    
    private func matchesSearchCriteria(_ post: LocationPost, searchText: String) -> Bool {
        post.title?.localizedCaseInsensitiveContains(searchText) == true ||
        post.content.localizedCaseInsensitiveContains(searchText) ||
        post.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    private func loadInitialData() {
        posts = [
            LocationPost(
                title: "有一起打球的的吗",
                content: "今天早上我有个计划，就是去入管局办理一些手续。最近一直忙着工作，所以这件事拖了好久。想着今天正好有空，赶紧去处理一下。",
                authorName: "劉子源",
                locationName: "東京都 葛飾区 立石",
                latitude: 35.681236,
                longitude: 139.767125,
                imageNames: ["sample1", "reco_2", "reco_3"],
                avatarImage: "sample2",
                tags: ["娱乐", "运动", "篮球"],
                participantsCount: 99,
                postedTime: "10 mins",
                remainingDays: "3 days",
                publishDate: "2024-10-01",
                joinedCount: "75＋",
                cachedDistance: 300
            ),
            LocationPost(
                title: "一起去看电影吧",
                content: "最近上映了一部很不错的电影，有兴趣的朋友一起去看吧！",
                authorName: "王小明",
                locationName: "東京都 新宿区",
                latitude: 35.689487,
                longitude: 139.700706,
                imageNames: ["4_3", "4_5"],
                avatarImage: "sample2",
                tags: ["娱乐", "电影", "社交"],
                participantsCount: 56,
                postedTime: "20 mins",
                remainingDays: "2 days",
                publishDate: "2024-10-02",
                joinedCount: "45＋",
                cachedDistance: 500
            )
        ]
        filteredPosts = posts
    }
}
