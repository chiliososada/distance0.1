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
    @Published private(set) var visiblePlaces: [Place] = []
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
        
        func addRegion(_ key: String, places: [Place]) {
            cache.setObject(places as NSArray, forKey: key as NSString)
            loadedRegions.insert(key)
        }
        
        func getPlaces(for key: String) -> [Place]? {
            guard loadedRegions.contains(key),
                  let places = cache.object(forKey: key as NSString) as? [Place] else {
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
    private let testDataSets: [String: [Place]] = {
        var dataSets: [String: [Place]] = [:]
        
        // 东京站附近的景点
        let tokyoStationSpots = [
            Place(name: "东京站", latitude: 35.681236, longitude: 139.767125, sponsored: true),
            Place(name: "丸之内大楼", latitude: 35.680959, longitude: 139.766424),
            Place(name: "KITTE", latitude: 35.679887, longitude: 139.764699),
            Place(name: "皇居", latitude: 35.685175, longitude: 139.752799, sponsored: true),
            Place(name: "东京国际论坛", latitude: 35.678795, longitude: 139.763328),
            Place(name: "大手町", latitude: 35.686274, longitude: 139.766207)
        ]
        dataSets["tokyo_station"] = tokyoStationSpots
        
        // 涉谷区域的景点
        let shibuyaSpots = [
            Place(name: "涉谷十字路口", latitude: 35.659494, longitude: 139.700292, sponsored: true),
            Place(name: "忠犬八公像", latitude: 35.659039, longitude: 139.700256),
            Place(name: "涉谷109", latitude: 35.659055, longitude: 139.703581),
            Place(name: "代代木公园", latitude: 35.671736, longitude: 139.695444),
            Place(name: "明治神宫", latitude: 35.676466, longitude: 139.699501, sponsored: true)
        ]
        dataSets["shibuya"] = shibuyaSpots
        
        // 浅草区域的景点
        let asakusaSpots = [
            Place(name: "浅草寺", latitude: 35.714839, longitude: 139.796649, sponsored: true),
            Place(name: "雷门", latitude: 35.711438, longitude: 139.796669),
            Place(name: "仲见世商店街", latitude: 35.712074, longitude: 139.796444),
            Place(name: "隅田公园", latitude: 35.714674, longitude: 139.801422),
            Place(name: "东京晴空塔", latitude: 35.710063, longitude: 139.810700, sponsored: true)
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
        let allPlaces: [Place]
        if let cachedPlaces = await cacheManager.getPlaces(for: regionKey) {
            allPlaces = cachedPlaces
        } else {
            allPlaces = fetchPlacesFromServer(in: region)
            await cacheManager.addRegion(regionKey, places: allPlaces)
        }
        
        // 计算距离并排序
        let sortedPlaces = allPlaces
            .map { place -> Place in
                let placeLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
                let centerLocation = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
                place.cachedDistance = placeLocation.distance(from: centerLocation)
                return place
            }
            .sorted { ($0.cachedDistance ?? 0) < ($1.cachedDistance ?? 0) }
            .prefix(LoadingConstants.visibleAnnotationsLimit)
        
        // 批量更新 visiblePlaces
        await updateVisiblePlacesInBatches(Array(sortedPlaces))
    }
    
    @MainActor
    private func updateVisiblePlacesInBatches(_ places: [Place]) async {
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
    
    private func fetchPlacesFromServer(in region: MKCoordinateRegion) -> [Place] {
        var nearbyPlaces: [Place] = []
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

