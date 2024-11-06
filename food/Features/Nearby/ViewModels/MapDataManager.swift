//
//  Untitled.swift
//  food
//
//  Created by toyousoft on 2024/11/04.
//

import SwiftUI
import MapKit

// MARK: - MapDataManager
final class MapDataManager: ObservableObject {
    // 添加分块加载的常量
      private enum LoadingConstants {
          static let maxAnnotationsPerBatch = 100
          static let batchLoadDelay: TimeInterval = 0.1
          static let visibleAnnotationsLimit = 200
      }
    // MARK: - Constants
    private enum Constants {
        static let cacheLimit = 50
        static let cacheSizeLimit = 50 * 1024 * 1024 // 50MB
        static let updateThrottle: TimeInterval = 0.3
        static let gridSize = 0.01 // 网格大小为0.01经纬度
        static let surroundingOffsets = [-1, 0, 1]
    }
    
    // MARK: - Published Properties
    @Published private(set) var visiblePlaces: [LocationPost] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    // MARK: - Private Properties
    private actor CacheManager {
        var loadedRegions: Set<String> = []
        let cache = NSCache<NSString, NSArray>()
        
        init() {
            cache.countLimit = Constants.cacheLimit
            cache.totalCostLimit = Constants.cacheSizeLimit
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
    
    private let cacheManager = CacheManager()
    private let queue = DispatchQueue(label: "com.app.mapdatamanager", qos: .userInitiated)
    private var lastLoadTime: Date = .distantPast
    private var loadingTasks: [String: Task<Void, Never>] = [:]
    
    // MARK: - Test Data
    // Test Data
    private let testDataSets: [String: [LocationPost]] = {
        var dataSets: [String: [LocationPost]] = [:]
        
        // 东京站附近的景点
        let tokyoStationSpots = [
            LocationPost(
                title: "东京站",
                content: "东京的中心交通枢纽",
                authorName: "liuziyuan",
                locationName: "東京都千代田区丸の内1丁目",
                latitude: 35.681236,
                longitude: 139.767125,
                imageNames: ["sample1", "sample2"],
                avatarImage: "sample1",
                tags: ["地标", "交通", "购物"],
                participantsCount: 0,
                postedTime: "刚刚",
                remainingDays: "长期",
                publishDate: "2024-01-01",
                joinedCount: "100+",
                isSponsored: true
            ),
            LocationPost(
                title: "丸之内大楼",
                content: "著名的办公楼和商业设施",
                authorName: "liuziyuan",
                locationName: "東京都千代田区丸の内2丁目",
                latitude: 35.680959,
                longitude: 139.766424,
                imageNames: ["sample1", "sample2", "sample3"],
                avatarImage: "sample1",
                tags: ["商业", "办公", "美食"],
                participantsCount: 0,
                postedTime: "刚刚",
                remainingDays: "长期",
                publishDate: "2024-01-01",
                joinedCount: "50+"
            ),
            LocationPost(
                title: "KITTE",
                content: "购物和美食天堂",
                authorName: "系统",
                locationName: "東京都千代田区丸の内2丁目",
                latitude: 35.679887,
                longitude: 139.764699,
                imageNames: ["sample1", "sample2", "sample3", "sample4"],
                avatarImage: "sample1",
                tags: ["购物", "美食", "文化"],
                participantsCount: 0,
                postedTime: "刚刚",
                remainingDays: "长期",
                publishDate: "2024-01-01",
                joinedCount: "80+"
            )
        ]
        dataSets["tokyo_station"] = tokyoStationSpots
        
        // 涉谷区域的景点
        let shibuyaSpots = [
            LocationPost(
                title: "涉谷十字路口",
                content: "世界著名的繁忙路口",
                authorName: "系统",
                locationName: "東京都渋谷区",
                latitude: 35.659494,
                longitude: 139.700292,
                imageNames: ["shibuya_crossing"],
                avatarImage: "system_avatar",
                tags: ["地标", "观光", "购物"],
                participantsCount: 0,
                postedTime: "刚刚",
                remainingDays: "长期",
                publishDate: "2024-01-01",
                joinedCount: "200+",
                isSponsored: true
            ),
            LocationPost(
                title: "涉谷109",
                content: "年轻人的时尚中心",
                authorName: "系统",
                locationName: "東京都渋谷区",
                latitude: 35.659055,
                longitude: 139.703581,
                imageNames: ["shibuya_109"],
                avatarImage: "system_avatar",
                tags: ["购物", "时尚", "美食"],
                participantsCount: 0,
                postedTime: "刚刚",
                remainingDays: "长期",
                publishDate: "2024-01-01",
                joinedCount: "150+"
            )
        ]
        dataSets["shibuya"] = shibuyaSpots
        
        // 浅草区域的景点
        let asakusaSpots = [
            LocationPost(
                title: "浅草寺",
                content: "东京最古老的寺庙",
                authorName: "系统",
                locationName: "東京都台東区",
                latitude: 35.714839,
                longitude: 139.796649,
                imageNames: ["sensoji"],
                avatarImage: "system_avatar",
                tags: ["文化", "历史", "观光"],
                participantsCount: 0,
                postedTime: "刚刚",
                remainingDays: "长期",
                publishDate: "2024-01-01",
                joinedCount: "300+",
                isSponsored: true
            ),
            LocationPost(
                title: "晴空塔",
                content: "东京的新地标",
                authorName: "系统",
                locationName: "東京都墨田区",
                latitude: 35.710063,
                longitude: 139.810700,
                imageNames: ["skytree"],
                avatarImage: "system_avatar",
                tags: ["地标", "观光", "购物"],
                participantsCount: 0,
                postedTime: "刚刚",
                remainingDays: "长期",
                publishDate: "2024-01-01",
                joinedCount: "250+"
            )
        ]
        dataSets["asakusa"] = asakusaSpots
        
        return dataSets
    }()
    
    // MARK: - Initialization
    init() {
        setupNotifications()
        setupPeriodicCleanup()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    private func setupPeriodicCleanup() {
          Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
              Task { [weak self] in
                  await self?.performPeriodicCleanup()
              }
          }
      }
      
      private func performPeriodicCleanup() async {
          // 清理过期数据
          await cleanupExpiredData()
          // 检查并限制可见标注数量
          await limitVisibleAnnotations()
      }
      
      private func cleanupExpiredData() async {
          // 只保留最近访问的区域数据
          let allRegions = await cacheManager.loadedRegions
          if allRegions.count > Constants.cacheLimit / 2 {
              let regionsToRemove = allRegions.prefix(allRegions.count - Constants.cacheLimit / 2)
              for region in regionsToRemove {
                  await cacheManager.removeRegion(region)
              }
          }
      }
      
      private func limitVisibleAnnotations() async {
          if visiblePlaces.count > LoadingConstants.visibleAnnotationsLimit {
              visiblePlaces = Array(visiblePlaces.prefix(LoadingConstants.visibleAnnotationsLimit))
          }
      }
    // MARK: - Public Methods
    @MainActor
    func loadPlaces(in region: MKCoordinateRegion) async {
        let now = Date()
        guard now.timeIntervalSince(lastLoadTime) >= Constants.updateThrottle else { return }
        lastLoadTime = now
        
        isLoading = true
        defer { isLoading = false }
        
        let regionKey = getRegionKey(for: region)
        
        // 获取并处理所有地点
        let allPlaces: [LocationPost]
        if let cachedPlaces = await cacheManager.getPlaces(for: regionKey) {
            allPlaces = cachedPlaces
        } else {
            allPlaces = fetchPlacesFromServer(in: region)
            await cacheManager.addRegion(regionKey, places: allPlaces)
        }
        
        // 计算距离并排序
        let sortedPlaces = allPlaces
            .map { LocationPost -> LocationPost in
                let placeLocation = CLLocation(latitude: LocationPost.coordinate.latitude, longitude: LocationPost.coordinate.longitude)
                let centerLocation = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
                LocationPost.cachedDistance = placeLocation.distance(from: centerLocation)
                return LocationPost
            }
            .sorted { ($0.cachedDistance ?? 0) < ($1.cachedDistance ?? 0) }
            .prefix(LoadingConstants.visibleAnnotationsLimit)
        
        // 批量更新 visiblePlaces
        await updateVisiblePlacesInBatches(Array(sortedPlaces))
    }
    
    @MainActor
    private func updateVisiblePlacesInBatches(_ places: [LocationPost]) async {
        let batchSize = LoadingConstants.maxAnnotationsPerBatch
        for startIndex in stride(from: 0, to: places.count, by: batchSize) {
            let endIndex = min(startIndex + batchSize, places.count)
            let batch = Array(places[startIndex..<endIndex])
            
            // 在主线程更新UI
            if startIndex == 0 {
                visiblePlaces = batch
            } else {
                visiblePlaces.append(contentsOf: batch)
            }
            
            if endIndex < places.count {
                try? await Task.sleep(nanoseconds: UInt64(LoadingConstants.batchLoadDelay * 1_000_000_000))
            }
        }
    }
    
    @MainActor
    func cleanupInvisibleRegions(currentRegion: MKCoordinateRegion) async {
        let loadedRegions = await cacheManager.loadedRegions
        
        // 使用 async let 并发处理清理操作
        await withThrowingTaskGroup(of: Void.self) { group in
            for regionKey in loadedRegions where !isRegionOverlapping(regionKey: regionKey, with: currentRegion) {
                group.addTask {
                    await self.cacheManager.removeRegion(regionKey)
                }
            }
        }
    }
    
    @MainActor
    func prioritizeRegion(_ region: MKCoordinateRegion) async {
        await loadPlaces(in: region)
        await preloadSurroundingRegions(around: region)
    }
    
    // MARK: - Private Methods
    private func setupNotifications() {
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
    
    private func getRegionKey(for region: MKCoordinateRegion) -> String {
        let latGrid = Int(region.center.latitude / Constants.gridSize)
        let lonGrid = Int(region.center.longitude / Constants.gridSize)
        return "\(latGrid):\(lonGrid)"
    }
    
    private func fetchPlacesFromServer(in region: MKCoordinateRegion) -> [LocationPost] {
        var nearbyPlaces: [LocationPost] = []
        for (_, places) in testDataSets {
            for place in places where isCoordinate(place.coordinate, inRegion: region) {
                nearbyPlaces.append(place)
            }
        }
        return nearbyPlaces
    }
    
    private func preloadSurroundingRegions(around region: MKCoordinateRegion) async {
        let latDelta = region.span.latitudeDelta
        let lonDelta = region.span.longitudeDelta
        
        for latOffset in Constants.surroundingOffsets {
            for lonOffset in Constants.surroundingOffsets {
                guard latOffset != 0 || lonOffset != 0 else { continue }
                
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
    
    private func isRegionOverlapping(regionKey: String, with currentRegion: MKCoordinateRegion) -> Bool {
        let components = regionKey.split(separator: ":")
        guard components.count == 2,
              let latGrid = Int(components[0]),
              let lonGrid = Int(components[1]) else {
            return false
        }
        
        let regionLat = Double(latGrid) * Constants.gridSize
        let regionLon = Double(lonGrid) * Constants.gridSize
        
        let currentLatMin = currentRegion.center.latitude - currentRegion.span.latitudeDelta/2
        let currentLatMax = currentRegion.center.latitude + currentRegion.span.latitudeDelta/2
        let currentLonMin = currentRegion.center.longitude - currentRegion.span.longitudeDelta/2
        let currentLonMax = currentRegion.center.longitude + currentRegion.span.longitudeDelta/2
        
        return regionLat >= currentLatMin && regionLat <= currentLatMax &&
               regionLon >= currentLonMin && regionLon <= currentLonMax
    }
    
    private func isCoordinate(_ coordinate: CLLocationCoordinate2D, inRegion region: MKCoordinateRegion) -> Bool {
        let latDelta = region.span.latitudeDelta / 2.0
        let lonDelta = region.span.longitudeDelta / 2.0
        
        let minLat = region.center.latitude - latDelta
        let maxLat = region.center.latitude + latDelta
        let minLon = region.center.longitude - lonDelta
        let maxLon = region.center.longitude + lonDelta
        
        return (coordinate.latitude >= minLat &&
                coordinate.latitude <= maxLat &&
                coordinate.longitude >= minLon &&
                coordinate.longitude <= maxLon)
    }
}

