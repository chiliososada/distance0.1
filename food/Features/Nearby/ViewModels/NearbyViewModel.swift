import SwiftUI
import MapKit
import Combine

@MainActor
class NearbyViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var selectedPosts: [LocationPost] = []
    @Published var showBottomSheet: Bool = false
    @Published var showFilterView: Bool = false
    @Published var search: String = ""
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?
    
    // MARK: - Dependencies
    let mapDataManager: MapDataManager
    private let locationManager = LocationManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var searchDebounceTask: Task<Void, Never>?
    
    // MARK: - Private Properties
    private let searchDebounceInterval: TimeInterval = 0.3
    
    // MARK: - Computed Properties
    var visiblePlaces: [LocationPost] { mapDataManager.visiblePlaces }
    
    // MARK: - Initialization
       init() {
           // 直接创建依赖
           let queue = DispatchQueue(label: "com.app.mapdatamanager", qos: .userInitiated)
           self.mapDataManager = MapDataManager(locationService: PostLocationService.shared,
                                             queue: queue)
           setupBindings()
       }
    deinit {
        searchDebounceTask?.cancel()
        cancellables.forEach { $0.cancel() }
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
        
        selectedPosts = Array(Set(posts))  // 去重
        showBottomSheet = !selectedPosts.isEmpty
    }
    
    func handleMapRegionChange(_ region: MKCoordinateRegion) async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            await mapDataManager.loadPlaces(in: region)
            await mapDataManager.cleanupInvisibleRegions(currentRegion: region)
        } catch {
            self.error = error
        }
    }
    
    func prioritizeRegion(_ region: MKCoordinateRegion) async {
        do {
            await mapDataManager.prioritizeRegion(region)
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Button Action Handlers
    func handleHotspotsTap() {
        print("handleHotspotsTap")
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                if let hotspotRegion = await loadHotspotRegion() {
                    await prioritizeRegion(hotspotRegion)
                }
            } catch {
                self.error = error
            }
        }
    }
    
    func handleLocationTap() {
        print("handleLocationTap")
        Task {
            isLoading = true
            defer { isLoading = false }
        
            locationManager.startUpdatingLocation()
            
            // 使用 Combine 监听位置更新
            locationManager.$userLocation
                .compactMap { $0 }
                .first()
                .sink { [weak self] location in
                    Task {
                        let region = MKCoordinateRegion(
                            center: location.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                        )
                        await self?.prioritizeRegion(region)
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    func handleBuildingsTap() {
        Task {
            do {
                await toggleBuildingsDisplay()
            } catch {
                self.error = error
            }
        }
    }
    
    func handleWavesTap() {
        Task {
            do {
                await toggleSpecialLayer()
            } catch {
                self.error = error
            }
        }
    }
    
    // MARK: - Public Helper Methods
    func clearSelection() {
        selectedPosts = []
        showBottomSheet = false
    }
    
    func reset() {
        clearSelection()
        showFilterView = false
        search = ""
        error = nil
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // 搜索防抖
        $search
            .debounce(for: .seconds(searchDebounceInterval), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.performSearch(searchText)
            }
            .store(in: &cancellables)
        
        // 监听位置错误
        NotificationCenter.default.publisher(for: .locationError)
            .sink { [weak self] notification in
                if let error = notification.object as? Error {
                    self?.error = error
                }
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(_ searchText: String) {
        searchDebounceTask?.cancel()
        
        guard !searchText.isEmpty else {
            return
        }
        
        searchDebounceTask = Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                await searchPlaces(searchText)
            } catch {
                self.error = error
            }
        }
    }
    
    private func loadHotspotRegion() async -> MKCoordinateRegion? {
        // 实现热点区域加载逻辑
        return nil
    }
    
    private func searchPlaces(_ query: String) async {
        // 实现搜索逻辑，可以使用 locationManager.searchCompleterDelegate
    }
    
    private func toggleBuildingsDisplay() async {
        // 实现建筑物显示切换逻辑
    }
    
    private func toggleSpecialLayer() async {
        // 实现特殊图层切换逻辑
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let locationError = Notification.Name("locationError")
}
