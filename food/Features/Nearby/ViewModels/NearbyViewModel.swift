import SwiftUI
import MapKit
import Combine

@MainActor
class NearbyViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedPosts: [LocationPost] = []
    @Published var showBottomSheet: Bool = false
    @Published var showFilterView: Bool = false
    @Published var search: String = ""
    
    // MARK: - Dependencies
    private let mapDataManager: MapDataManager
    
    // MARK: - Computed Properties
    var isLoading: Bool { mapDataManager.isLoading }
    var error: Error? { mapDataManager.error }
    var visiblePlaces: [LocationPost] { mapDataManager.visiblePlaces }
    
    // MARK: - Initialization
    init(mapDataManager: MapDataManager = MapDataManager()) {
        self.mapDataManager = mapDataManager
    }
    
    // MARK: - Public Methods
    func updateSelectedPosts(from annotations: [MKAnnotation]) {
        let posts = annotations.compactMap { annotation -> [LocationPost] in
            if let post = annotation as? LocationPost {
                return [post]
            } else if let cluster = annotation as? MKClusterAnnotation {
                return cluster.memberAnnotations.compactMap { $0 as? LocationPost }
            }
            return []
        }.flatMap { $0 }
        
        selectedPosts = Array(posts)
        showBottomSheet = !selectedPosts.isEmpty
    }
    
    func handleMapRegionChange(_ region: MKCoordinateRegion) async {
        await mapDataManager.loadPlaces(in: region)
        await mapDataManager.cleanupInvisibleRegions(currentRegion: region)
    }
    
    func prioritizeRegion(_ region: MKCoordinateRegion) async {
        await mapDataManager.prioritizeRegion(region)
    }
    
    // MARK: - Button Action Handlers
    func handleHotspotsTap() {
        // 实现热点功能：显示热门区域或热门地点
        Task {
            // 这里可以添加具体实现
        }
    }
    
    func handleLocationTap() {
        // 实现定位功能：定位到用户当前位置
        Task {
            // 这里可以添加具体实现
        }
    }
    
    func handleBuildingsTap() {
        // 实现建筑功能：显示或隐藏建筑物
        Task {
            // 这里可以添加具体实现
        }
    }
    
    func handleWavesTap() {
        // 实现波浪功能：显示特定图层或效果
        Task {
            // 这里可以添加具体实现
        }
    }
}
