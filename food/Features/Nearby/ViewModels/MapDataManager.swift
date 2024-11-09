import SwiftUI
import MapKit

// MARK: - Constants
private enum MapConstants {
    enum Loading {
        static let maxAnnotationsPerBatch = 100
        static let batchLoadDelay: TimeInterval = 0.1
        static let visibleLimit = 200
        static let cleanupInterval: TimeInterval = 30
    }
    
    enum Cache {
        static let limit = 50
        static let sizeLimit = 50 * 1024 * 1024 // 50MB
        static let updateThrottle: TimeInterval = 0.3
    }
    
    enum Grid {
        static let size = 0.01 // 网格大小为0.01经纬度
        static let surroundingOffsets = [-1, 0, 1]
    }
}
@MainActor
final class MapDataManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var visiblePlaces: [LocationPost] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    // MARK: - Private Properties
    private let cacheManager: CacheManager
    private let locationService: PostLocationService
    private let queue: DispatchQueue
    private var lastLoadTime: Date
    private var cleanupTimer: Timer?
    private var loadingTasks: [String: Task<Void, Never>] = [:]
    
    init(locationService: PostLocationService,
           queue: DispatchQueue) {
          self.locationService = locationService
          self.cacheManager = CacheManager()
          self.queue = queue
          self.lastLoadTime = .distantPast
          setupNotifications()
          setupPeriodicCleanup()
      }
    // 提供一个便利初始化器
      @MainActor
      static func create() -> MapDataManager {
          let queue = DispatchQueue(label: "com.app.mapdatamanager", qos: .userInitiated)
          return MapDataManager(locationService: PostLocationService.shared, queue: queue)
      }
    
    deinit {
        cleanupTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Public Methods
extension MapDataManager {
    @MainActor
    func loadPlaces(in region: MKCoordinateRegion) async {
        guard shouldUpdateRegion() else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let regionKey = getRegionKey(for: region)
        let allPlaces = await fetchPlaces(for: regionKey, in: region)
        let sortedPlaces = await sortPlacesByDistance(allPlaces, from: region.center)
        await updateVisiblePlacesInBatches(Array(sortedPlaces))
    }
    
    @MainActor
    func cleanupInvisibleRegions(currentRegion: MKCoordinateRegion) async {
        await performRegionCleanup(for: currentRegion)
    }
    
    @MainActor
    func prioritizeRegion(_ region: MKCoordinateRegion) async {
        await loadPlaces(in: region)
        await preloadSurroundingRegions(around: region)
    }
}

// MARK: - Private Methods
private extension MapDataManager {
    func shouldUpdateRegion() -> Bool {
        let now = Date()
        guard now.timeIntervalSince(lastLoadTime) >= MapConstants.Cache.updateThrottle else {
            return false
        }
        lastLoadTime = now
        return true
    }
    
    func setupPeriodicCleanup() {
        cleanupTimer = Timer.scheduledTimer(
            withTimeInterval: MapConstants.Loading.cleanupInterval,
            repeats: true
        ) { [weak self] _ in
            Task { [weak self] in
                await self?.performPeriodicCleanup()
            }
        }
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { [weak self] in
                await self?.cacheManager.clearCache()
            }
        }
    }
    
    @MainActor
    func performPeriodicCleanup() async {
        await cleanupExpiredData()
        await limitVisibleAnnotations()
    }
    
    func cleanupExpiredData() async {
        let allRegions = await cacheManager.loadedRegions
        if allRegions.count > MapConstants.Cache.limit / 2 {
            let regionsToRemove = allRegions.prefix(allRegions.count - MapConstants.Cache.limit / 2)
            for region in regionsToRemove {
                await cacheManager.removeRegion(region)
            }
        }
    }
    
    @MainActor
    func limitVisibleAnnotations() async {
        if visiblePlaces.count > MapConstants.Loading.visibleLimit {
            visiblePlaces = Array(visiblePlaces.prefix(MapConstants.Loading.visibleLimit))
        }
    }
    
    private func fetchPlaces(for regionKey: String, in region: MKCoordinateRegion) async -> [LocationPost] {
            if let cachedPlaces = await cacheManager.getPlaces(for: regionKey) {
                return cachedPlaces
            }
            
            do {
                try await locationService.fetchPosts(in: region)
                let places = locationService.posts
                await cacheManager.addRegion(regionKey, places: places)
                return places
            } catch {
                self.error = error
                return []
            }
        }
    
    func sortPlacesByDistance(_ places: [LocationPost], from center: CLLocationCoordinate2D) async -> [LocationPost] {
        Array(
            places
                .map { place -> LocationPost in
                    let placeLocation = CLLocation(latitude: place.coordinate.latitude,
                                                 longitude: place.coordinate.longitude)
                    let centerLocation = CLLocation(latitude: center.latitude,
                                                  longitude: center.longitude)
                    place.cachedDistance = placeLocation.distance(from: centerLocation)
                    return place
                }
                .sorted { ($0.cachedDistance ?? 0) < ($1.cachedDistance ?? 0) }
                .prefix(MapConstants.Loading.visibleLimit)
        )
    }
    
    @MainActor
    func updateVisiblePlacesInBatches(_ places: [LocationPost]) async {
        let batchSize = MapConstants.Loading.maxAnnotationsPerBatch
        for startIndex in stride(from: 0, to: places.count, by: batchSize) {
            let endIndex = min(startIndex + batchSize, places.count)
            let batch = Array(places[startIndex..<endIndex])
            
            if startIndex == 0 {
                visiblePlaces = batch
            } else {
                visiblePlaces.append(contentsOf: batch)
            }
            
            if endIndex < places.count {
                try? await Task.sleep(nanoseconds: UInt64(MapConstants.Loading.batchLoadDelay * 1_000_000_000))
            }
        }
    }
    
    func getRegionKey(for region: MKCoordinateRegion) -> String {
        let latGrid = Int(region.center.latitude / MapConstants.Grid.size)
        let lonGrid = Int(region.center.longitude / MapConstants.Grid.size)
        return "\(latGrid):\(lonGrid)"
    }
    
    func preloadSurroundingRegions(around region: MKCoordinateRegion) async {
        let latDelta = region.span.latitudeDelta
        let lonDelta = region.span.longitudeDelta
        
        for latOffset in MapConstants.Grid.surroundingOffsets {
            for lonOffset in MapConstants.Grid.surroundingOffsets where !(latOffset == 0 && lonOffset == 0) {
                let newCenter = CLLocationCoordinate2D(
                    latitude: region.center.latitude + Double(latOffset) * latDelta,
                    longitude: region.center.longitude + Double(lonOffset) * lonDelta
                )
                
                let surroundingRegion = MKCoordinateRegion(
                    center: newCenter,
                    span: region.span
                )
                
                await loadPlaces(in: surroundingRegion)
            }
        }
    }
    
    @MainActor
    func performRegionCleanup(for currentRegion: MKCoordinateRegion) async {
        let loadedRegions = await cacheManager.loadedRegions
        await withTaskGroup(of: Void.self) { group in
            for regionKey in loadedRegions where !isRegionOverlapping(regionKey: regionKey,
                                                                    with: currentRegion) {
                group.addTask {
                    await self.cacheManager.removeRegion(regionKey)
                }
            }
        }
    }
    
    func isRegionOverlapping(regionKey: String, with currentRegion: MKCoordinateRegion) -> Bool {
        let components = regionKey.split(separator: ":")
        guard components.count == 2,
              let latGrid = Int(components[0]),
              let lonGrid = Int(components[1]) else {
            return false
        }
        
        let regionLat = Double(latGrid) * MapConstants.Grid.size
        let regionLon = Double(lonGrid) * MapConstants.Grid.size
        
        let currentLatMin = currentRegion.center.latitude - currentRegion.span.latitudeDelta/2
        let currentLatMax = currentRegion.center.latitude + currentRegion.span.latitudeDelta/2
        let currentLonMin = currentRegion.center.longitude - currentRegion.span.longitudeDelta/2
        let currentLonMax = currentRegion.center.longitude + currentRegion.span.longitudeDelta/2
        
        return regionLat >= currentLatMin && regionLat <= currentLatMax &&
        regionLon >= currentLonMin && regionLon <= currentLonMax
    }
}

// MARK: - CacheManager
private actor CacheManager {
    var loadedRegions: Set<String> = []
    private let cache: NSCache<NSString, NSArray>
    
    init() {
        self.cache = NSCache<NSString, NSArray>()
        self.cache.countLimit = MapConstants.Cache.limit
        self.cache.totalCostLimit = MapConstants.Cache.sizeLimit
    }
    
    func clearCache() {
        cache.removeAllObjects()
        loadedRegions.removeAll()
    }
    
    func addRegion(_ key: String, places: [LocationPost]) {
        cache.setObject(places as NSArray, forKey: key as NSString)
        loadedRegions.insert(key)
    }
    
    func getPlaces(for key: String) -> [LocationPost]? {
        guard loadedRegions.contains(key),
              let places = cache.object(forKey: key as NSString) as? [LocationPost] else {
            return nil
        }
        return places
    }
    
    func removeRegion(_ key: String) {
        loadedRegions.remove(key)
        cache.removeObject(forKey: key as NSString)
    }
}
