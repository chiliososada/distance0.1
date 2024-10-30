import SwiftUI
import MapKit



// MARK: - Place Model
class Place: NSObject, MKAnnotation, Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let image: String
    let sponsored: Bool
    
    // 使用计算属性包装私有存储属性
    private var _cachedDistance: Double?
    var cachedDistance: Double? {
        get { _cachedDistance }
        set { _cachedDistance = newValue }
    }
    
    var title: String? { name }
    
    init(id: String = UUID().uuidString,
         name: String,
         latitude: Double,
         longitude: Double,
         sponsored: Bool = false) {
        self.id = id
        self.name = name
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.image = "placeholder"
        self.sponsored = sponsored
        super.init()
    }
}

extension Place {
    func updateDistance(from coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let placeLocation = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
        self.cachedDistance = placeLocation.distance(from: location)
    }
    
    func isWithinDistance(_ threshold: Double, from coordinate: CLLocationCoordinate2D) -> Bool {
        if cachedDistance == nil {
            updateDistance(from: coordinate)
        }
        return cachedDistance ?? .infinity <= threshold
    }
}
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




// MARK: - ClusterMapView
struct ClusterMapView: UIViewRepresentable {
    // MARK: - Constants
    private enum Constants {
        static let updateThrottle: TimeInterval = 0.5
        static let defaultLatitude = 35.681236
        static let defaultLongitude = 139.767125
        static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        static let clusterSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        static let singlePlaceSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        
        enum AnnotationType {
            static let cluster = "cluster"
            static let place = "InterestingPlace"
        }
        
        static let markerTintColor = UIColor(displayP3Red: 0.082, green: 0.518, blue: 0.263, alpha: 1.0)
    }
    
    // MARK: - Properties
    @StateObject private var dataManager = MapDataManager()
    @Binding var showBottomSheet: Bool
    @Binding var selectedPlaceNames: [String]
    
    // MARK: - Coordinator
    class Coordinator: NSObject, MKMapViewDelegate {
        // MARK: - Properties
        private let parent: ClusterMapView
        private var lastUpdateTime: Date = Date()
        private let throttleInterval: TimeInterval
        
        // MARK: - Initialization
        init(parent: ClusterMapView, throttleInterval: TimeInterval = Constants.updateThrottle) {
            self.parent = parent
            self.throttleInterval = throttleInterval
            super.init()
        }
        
        // MARK: - MapView Delegate Methods
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            Task {
                guard shouldUpdateRegion() else { return }
                await updateMapAnnotations(in: mapView)
            }
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
           
            switch annotation {
            case let cluster as MKClusterAnnotation:
                return setupClusterAnnotationView(for: cluster, in: mapView)
            case is Place:
                return setupPlaceAnnotationView(for: annotation, in: mapView)
            default:
                return nil
            }
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            parent.showBottomSheet = true  // 确保底部表单显示
            Task {
                await handleAnnotationSelection(view, in: mapView)
            }
        }
        
        // MARK: - Private Helper Methods
        private func shouldUpdateRegion() -> Bool {
            let currentTime = Date()
            guard currentTime.timeIntervalSince(lastUpdateTime) >= throttleInterval else {
                return false
            }
            lastUpdateTime = currentTime
            return true
        }
        
        @MainActor
        private func updateMapAnnotations(in mapView: MKMapView) async {
            let visibleRegion = mapView.region
            
            // 更新数据
            await parent.dataManager.loadPlaces(in: visibleRegion)
            await parent.dataManager.cleanupInvisibleRegions(currentRegion: visibleRegion)
            
            // 获取当前显示的标注
            let currentAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
            let currentIds = Set(currentAnnotations.compactMap { ($0 as? Place)?.id })
            
            // 获取新的标注
            let newPlaces = parent.dataManager.visiblePlaces
            let newIds = Set(newPlaces.map { $0.id })
            
            // 计算需要添加和移除的标注
            let annotationsToRemove = currentAnnotations.filter { annotation in
                guard let place = annotation as? Place else { return true }
                return !newIds.contains(place.id)
            }
            
            let placesToAdd = newPlaces.filter { !currentIds.contains($0.id) }
            
            // 批量更新
            if !annotationsToRemove.isEmpty {
                mapView.removeAnnotations(annotationsToRemove)
            }
            
            if !placesToAdd.isEmpty {
                mapView.addAnnotations(placesToAdd)
            }
        }
        
        private func setupClusterAnnotationView(for cluster: MKClusterAnnotation, in mapView: MKMapView) -> MKMarkerAnnotationView {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.AnnotationType.cluster) as? MKMarkerAnnotationView
                ?? MKMarkerAnnotationView(annotation: cluster, reuseIdentifier: Constants.AnnotationType.cluster)
            
            configureBaseAnnotationView(annotationView)
            configureClusterTitle(for: cluster)
            
            return annotationView
        }
        
        private func setupPlaceAnnotationView(for annotation: MKAnnotation, in mapView: MKMapView) -> MKMarkerAnnotationView {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.AnnotationType.place) as? MKMarkerAnnotationView
                ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationType.place)
            
            configureBaseAnnotationView(annotationView)
            configurePlaceAnnotation(annotationView)
            
            return annotationView
        }
        
        private func configureBaseAnnotationView(_ view: MKMarkerAnnotationView) {
            view.markerTintColor = Constants.markerTintColor
            view.canShowCallout = true
            view.isEnabled = true
            view.isDraggable = false
            view.titleVisibility = .visible
        }
        
        private func configurePlaceAnnotation(_ view: MKMarkerAnnotationView) {
            view.glyphText = "💬"
            view.clusteringIdentifier = Constants.AnnotationType.cluster
        }
        
        private func configureClusterTitle(for cluster: MKClusterAnnotation) {
            let sponsoredPlace = cluster.memberAnnotations
                .compactMap { $0 as? Place }
                .first { $0.sponsored }
            
            cluster.title = sponsoredPlace?.name ?? "\(cluster.memberAnnotations.count) 个地点"
        }
        
        @MainActor
        private func handleAnnotationSelection(_ view: MKAnnotationView, in mapView: MKMapView) async {
            parent.showBottomSheet = true
            
            if let cluster = view.annotation as? MKClusterAnnotation {
                await handleClusterSelection(cluster)
            } else if let place = view.annotation as? Place {
                await handlePlaceSelection(place)
            }
            
            mapView.deselectAnnotation(view.annotation, animated: true)
        }
        
        @MainActor
        private func handleClusterSelection(_ cluster: MKClusterAnnotation) async {
            let (sponsoredPlaces, normalPlaces) = cluster.memberAnnotations
                .compactMap { $0 as? Place }
                .reduce(into: ([String](), [String]())) { result, place in
                    if place.sponsored {
                        result.0.append(place.name)
                    } else {
                        result.1.append(place.name)
                    }
                }
            
            // 更新状态
              parent.showBottomSheet = true  // 确保底部表单显示
              parent.selectedPlaceNames = sponsoredPlaces + normalPlaces
            
            let region = MKCoordinateRegion(
                center: cluster.coordinate,
                span: Constants.clusterSpan
            )
            await parent.dataManager.prioritizeRegion(region)
        }
        
        @MainActor
        private func handlePlaceSelection(_ place: Place) async {
            parent.showBottomSheet = true  // 确保底部表单显示
            parent.selectedPlaceNames = [place.name]
            
            let region = MKCoordinateRegion(
                center: place.coordinate,
                span: Constants.singlePlaceSpan
            )
            await parent.dataManager.prioritizeRegion(region)
        }
    }
    
    // MARK: - UIViewRepresentable Methods
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        configureMapView(mapView, with: context.coordinator)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 保持为空，因为我们使用委托来处理更新
    }
    
    // MARK: - Private Helper Methods
    private func configureMapView(_ mapView: MKMapView, with coordinator: Coordinator) {
        // 基本设置
        mapView.delegate = coordinator
        
        // 注册标注视图
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: Constants.AnnotationType.place)
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: Constants.AnnotationType.cluster)
        
        // 地图功能设置
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsTraffic = false
        mapView.showsBuildings = false
        
        // 隐藏POI
        mapView.pointOfInterestFilter = .excludingAll
        
        // 设置初始区域
        let initialRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: Constants.defaultLatitude,
                longitude: Constants.defaultLongitude
            ),
            span: Constants.defaultSpan
        )
        mapView.setRegion(initialRegion, animated: false)
    }
}

struct NearbyView: View {

     @StateObject private var dataManager = MapDataManager()
     @State private var showBottomSheet = false
     @State private var selectedPlaceNames: [String] = []
     @State private var search: String = ""
     @State private var showFilterView = false
    
    var body: some View {
        ZStack {
            // 地图放在底部，只忽略顶部和左右的安全区域
            ClusterMapView(
                           showBottomSheet: $showBottomSheet,
                           selectedPlaceNames: $selectedPlaceNames
                       )
                       .edgesIgnoringSafeArea([.top, .leading, .trailing])
            
            // 按钮内容放在地图之上，顶部显示
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        // 搜索框
                        HStack(spacing: 8) {  // 减少HStack的间距
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                TextField("请输入要查找的话题，标签等...", text: $search)
                                    .padding(.vertical, 2)  // 减少 TextField 的内边距
                                    .font(.system(size: 14, weight: .regular))  // 调整字体大小
                                    .foregroundColor(.black)
                                    .accentColor(.gray)
                            }
                            .padding(8)  // 减少HStack内的padding
                            .background(Color(UIColor.white))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)  // Gray border with 1 point thickness
                            )
                            // 过滤按钮
                            Button(action: {
                                showFilterView.toggle()  // 点击显示过滤器视图
                            }) {
                                Image(systemName: "slider.horizontal.3")
                                    .foregroundColor(.black)
                                    .padding(8)  // 减少按钮的padding
                                    .background(Color(UIColor.white))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray, lineWidth: 1)  // Gray border with 1 point thickness
                                    )
                            }
                            
                        }
                        .padding(.horizontal)  // 仅调整左右两侧的padding，保持上下的紧凑布局
                        HStack(spacing: 10) { // 内部 VStack 使按钮垂直排列
                            Button {
                                
                            } label: {
                                Label("", systemImage: "flame.fill")
                            }
                            .buttonStyle(.borderedProminent)

                            Button {
                                
                            } label: {
                                Label("", systemImage: "location.fill")
                            }
                            .buttonStyle(.bordered)

                            Button {
//                                position = .region(.boston)
                            } label: {
                                Label("", systemImage: "building.2")
                            }
                            .buttonStyle(.bordered)

                            Button {
//                                position = .region(.northShore)
                            } label: {
                                Label("", systemImage: "water.waves")
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    
                    .padding(.top, 40)  // 正确的语法
                    Spacer()
                }
                Spacer() // 保持按钮在顶部
            }
        }
        .background(Color.clear) // 使用系统的 Material 背景样式
        .sheet(isPresented: $showBottomSheet) {
            // 底部弹出 BottomMenuView
            BottomMenuView(placeNames: selectedPlaceNames)
                .presentationDetents([.fraction(0.5), .large]) // 可选：定义 BottomMenuView 的高度
        }
        // 用 .sheet 来展示底部弹出的过滤视图
        .sheet(isPresented: $showFilterView) {
            SearchFilterView(showFilterView: $showFilterView)  // 将 showFilterView 传递给 sheet 内容
        }
    }
}

// 预览
struct NearbyView_Previews: PreviewProvider {
    static var previews: some View {
        NearbyView()
    }
}


struct BottomMenuView: View {
    let placeNames: [String]
    @State private var showSponsored: Bool = true
    
    var body: some View {
        VStack {
            // 显示选中的地点数量
            Text("Selected Places (\(placeNames.count))")
                .font(.headline)
                .padding()
            
            // 使用 ScrollView 显示地点列表
            ScrollView {
                LazyVStack(spacing: 16) {
                    // 将 placeNames 转换为可识别的数据结构
                    ForEach(Array(placeNames.enumerated()), id: \.element) { index, name in
                        RecipeCard(
                            recipe: RecommendedRecipe(
                                imageName: "fresh_recipe_1",
                                title: name,
                                imageNames: ["fresh_recipe_1", "fresh_recipe_1"],
                                authorName: "Place Owner",
                                location: "Location",
                                tags: ["Tag1", "Tag2"],
                                participantsCount: 0,
                                postedTime: "Just now",
                                distance: 100,
                                isLiked: false,
                                // 新增属性的值
                                avatarImage: "sample2",
                                remainingDays: "3 days",
                                publishDate: "2024-10-01",
                                joinedCount: "75＋",
                                content: "今天早上我有个计划，就是去入管局办理一些手续。最近一直忙着工作，所以这件事拖了好久。想着今天正好有空，赶紧去处理一下。"
                            )
                           
                        )
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    }
                }
            }
        }
        .padding()
    }
}

