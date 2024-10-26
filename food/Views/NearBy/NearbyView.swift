import SwiftUI
import MapKit



// 自定义的 Place 模型
class Place: NSObject, MKAnnotation, Identifiable {
    let id: String // 添加唯一标识符
    let name: String
    let coordinate: CLLocationCoordinate2D
    let image: String
    let sponsored: Bool
    var cachedDistance: Double? // 缓存距离计算结果
    
    var title: String? { name }
    
    init(id: String = UUID().uuidString, name: String, latitude: Double, longitude: Double, sponsored: Bool = false) {
        self.id = id
        self.name = name
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.image = "placeholder"
        self.sponsored = sponsored
        super.init()
    }
}

class MapDataManager: ObservableObject {

        @Published private(set) var visiblePlaces: [Place] = []
        @Published private(set) var isLoading = false
        @Published private(set) var error: Error?
        
        private var allPlaces: [Place] = []// 存储所有可能的地点数据
        private var loadedRegions: Set<String> = []   // 追踪已加载的区域
        private let queue = DispatchQueue(label: "com.app.mapdatamanager", qos: .userInitiated)
        private let cache = NSCache<NSString, NSArray>()
        private var loadingTasks: [String: Task<Void, Never>] = [:] // 追踪加载任务
        
        // 添加节流控制
        private var lastLoadTime: Date = .distantPast
        private let minimumLoadInterval: TimeInterval = 0.3
    init() {
        // 设置缓存限制
        cache.countLimit = 50 // 最多缓存50个区域的数据
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB 限制
        
        setupMemoryWarningNotification()
    }
    private func setupMemoryWarningNotification() {
          NotificationCenter.default.addObserver(
              self,
              selector: #selector(handleMemoryWarning),
              name: UIApplication.didReceiveMemoryWarningNotification,
              object: nil
          )
      }
      @objc private func handleMemoryWarning() {
            queue.async { [weak self] in
                self?.cache.removeAllObjects()
                self?.loadedRegions.removeAll()
            }
        }
    // 加载指定区域的数据
    func loadPlaces(in region: MKCoordinateRegion) {
         // 检查加载频率
         let now = Date()
         guard now.timeIntervalSince(lastLoadTime) >= minimumLoadInterval else { return }
         lastLoadTime = now
         
         // 取消之前的加载任务
         loadingTasks.values.forEach { $0.cancel() }
         
         let task = Task { [weak self] in
             guard let self = self else { return }
             
             do {
                 self.isLoading = true
                 let regionKey = self.getRegionKey(for: region)
                 
                 // 检查缓存
                 if let places = try await self.getCachedPlaces(for: regionKey) {
                     await self.updateVisiblePlaces(places)
                     return
                 }
                 
                 // 加载新数据
                 let newPlaces = try await self.fetchPlacesFromServer(in: region)
                 try await self.cachePlaces(newPlaces, for: regionKey)
                 await self.updateVisiblePlaces(newPlaces)
                 
             } catch {
                 await self.handleError(error)
             }
             
             self.isLoading = false
         }
         
         let regionKey = getRegionKey(for: region)
         loadingTasks[regionKey] = task
     }
    private func getCachedPlaces(for key: String) async throws -> [Place]? {
          return await withCheckedContinuation { continuation in
              queue.async { [weak self] in
                  guard let self = self,
                        self.loadedRegions.contains(key),
                        let places = self.cache.object(forKey: key as NSString) as? [Place] else {
                      continuation.resume(returning: nil)
                      return
                  }
                  continuation.resume(returning: places)
              }
          }
      }
    private func cachePlaces(_ places: [Place], for key: String) async throws {
            await withCheckedContinuation { continuation in
                queue.async { [weak self] in
                    self?.cache.setObject(places as NSArray, forKey: key as NSString)
                    self?.loadedRegions.insert(key)
                    continuation.resume()
                }
            }
        }
    @MainActor
      private func updateVisiblePlaces(_ places: [Place]) {
          visiblePlaces = places
      }
      
      @MainActor
      private func handleError(_ error: Error) {
          self.error = error
      }
    // 清理不可见区域的数据
    func cleanupInvisibleRegions(currentRegion: MKCoordinateRegion) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let currentRegionKey = self.getRegionKey(for: currentRegion)
            let regionsToRemove = self.loadedRegions.filter { regionKey in
                // 检查该区域是否与当前可见区域重叠
                !self.isRegionOverlapping(regionKey: regionKey, with: currentRegion)
            }
            
            // 移除不可见区域的数据
            for regionKey in regionsToRemove {
                self.loadedRegions.remove(regionKey)
                self.cache.removeObject(forKey: regionKey as NSString)
            }
        }
    }
    
    // 生成区域的唯一标识符
    private func getRegionKey(for region: MKCoordinateRegion) -> String {
        // 将区域划分为网格，每个网格大小为0.01经纬度
        let latGrid = Int(region.center.latitude * 100)
        let lonGrid = Int(region.center.longitude * 100)
        return "\(latGrid):\(lonGrid)"
    }
    
    // 检查两个区域是否重叠
    private func isRegionOverlapping(regionKey: String, with currentRegion: MKCoordinateRegion) -> Bool {
        let components = regionKey.split(separator: ":")
        guard components.count == 2,
              let latGrid = Int(components[0]),
              let lonGrid = Int(components[1]) else {
            return false
        }
        
        let regionLat = Double(latGrid) / 100.0
        let regionLon = Double(lonGrid) / 100.0
        
        let currentLatMin = currentRegion.center.latitude - currentRegion.span.latitudeDelta/2
        let currentLatMax = currentRegion.center.latitude + currentRegion.span.latitudeDelta/2
        let currentLonMin = currentRegion.center.longitude - currentRegion.span.longitudeDelta/2
        let currentLonMax = currentRegion.center.longitude + currentRegion.span.longitudeDelta/2
        
        return regionLat >= currentLatMin && regionLat <= currentLatMax &&
               regionLon >= currentLonMin && regionLon <= currentLonMax
    }
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

    private func fetchPlacesFromServer(in region: MKCoordinateRegion) -> [Place] {
            // 根据区域返回相应的测试数据
            var nearbyPlaces: [Place] = []
            
            // 检查请求的区域是否与预设的测试数据区域重叠
            for (_, places) in testDataSets {
                for place in places {
                    // 检查地点是否在请求的区域内
                    if isCoordinate(place.coordinate, inRegion: region) {
                        nearbyPlaces.append(place)
                    }
                }
            }

            
            return nearbyPlaces
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

// 在 MapDataManager 中添加优化方法
extension MapDataManager {
    // 优先加载特定区域的数据
    func prioritizeRegion(_ region: MKCoordinateRegion) {
        queue.async { [weak self] in
            // 立即加载该区域的数据
            self?.loadPlaces(in: region)
            
            // 可以在这里实现预加载逻辑
            // 例如，加载周围区域的数据
            self?.preloadSurroundingRegions(around: region)
        }
    }
    
    // 预加载周围区域的数据
    private func preloadSurroundingRegions(around region: MKCoordinateRegion) {
        // 计算周围8个区域
        let latDelta = region.span.latitudeDelta
        let lonDelta = region.span.longitudeDelta
        
        for latOffset in [-1, 0, 1] {
            for lonOffset in [-1, 0, 1] {
                if latOffset == 0 && lonOffset == 0 { continue }
                
                let newCenter = CLLocationCoordinate2D(
                    latitude: region.center.latitude + Double(latOffset) * latDelta,
                    longitude: region.center.longitude + Double(lonOffset) * lonDelta
                )
                
                let surroundingRegion = MKCoordinateRegion(
                    center: newCenter,
                    span: region.span
                )
                
                // 低优先级加载周围区域
                loadPlaces(in: surroundingRegion)
            }
        }
    }
}




// 自定义的 MapView 使用 MKMapView
struct ClusterMapView: UIViewRepresentable {
    //let places: [Place]
    @StateObject private var dataManager = MapDataManager()
    @Binding var showBottomSheet: Bool
    @Binding var selectedPlaceNames: [String]
    
    class Coordinator: NSObject, MKMapViewDelegate {
        //        @Binding var showBottomSheet: Bool
        //        @Binding var selectedPlaceNames: [String]
        
        var parent: ClusterMapView
        var lastUpdateTime: Date = Date()
        let updateThrottle: TimeInterval = 0.5 // 限制更新频率
        
        init(parent: ClusterMapView) {
            self.parent = parent
        }
        
        //        init(showBottomSheet: Binding<Bool>, selectedPlaceNames: Binding<[String]>) {
        //            _showBottomSheet = showBottomSheet
        //            _selectedPlaceNames = selectedPlaceNames
        //        }
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let currentTime = Date()
            guard currentTime.timeIntervalSince(lastUpdateTime) >= updateThrottle else { return }
            
            lastUpdateTime = currentTime
            
            let visibleRegion = mapView.region
            
            // 直接使用 dataManager
            self.parent.dataManager.loadPlaces(in: visibleRegion)
            self.parent.dataManager.cleanupInvisibleRegions(currentRegion: visibleRegion)
            
            // 更新地图上的标注
            let currentAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
            mapView.removeAnnotations(currentAnnotations)
            mapView.addAnnotations(self.parent.dataManager.visiblePlaces)
        }
        
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            switch annotation {
            case let cluster as MKClusterAnnotation:
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "cluster") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "cluster")
                annotationView.markerTintColor = UIColor(displayP3Red: 0.082, green: 0.518, blue: 0.263, alpha: 1.0)
                annotationView.canShowCallout = true
                
                annotationView.isEnabled = true
                annotationView.isDraggable = false
                
                var foundSponsored = false
                for clusterAnnotation in cluster.memberAnnotations {
                    if let place = clusterAnnotation as? Place, place.sponsored {
                        cluster.title = place.name
                        foundSponsored = true
                        break
                    }
                }
                if !foundSponsored {
                    cluster.title = "\(cluster.memberAnnotations.count) 个地点"
                }
                annotationView.titleVisibility = .visible
                return annotationView
                
            case let placeAnnotation as Place:
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "InterestingPlace") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "InterestingPlace")
                annotationView.canShowCallout = true
                annotationView.glyphText = "💬"
                annotationView.clusteringIdentifier = "cluster"
                annotationView.markerTintColor = UIColor(displayP3Red: 0.082, green: 0.518, blue: 0.263, alpha: 1.0)
                annotationView.titleVisibility = .visible
                
                annotationView.isEnabled = true
                annotationView.isDraggable = false
                
                return annotationView
                
            default:
                return nil
            }
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            withAnimation {
                self.parent.showBottomSheet = true
                if let cluster = view.annotation as? MKClusterAnnotation {
                    var sponsoredPlaces: [String] = []
                    var normalPlaces: [String] = []
                    
                    // 将地点分类
                    for member in cluster.memberAnnotations {
                        if let place = member as? Place {
                            if place.sponsored {
                                sponsoredPlaces.append(place.name)
                            } else {
                                normalPlaces.append(place.name)
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        // 合并数组，赞助地点在前
                        self.parent.selectedPlaceNames = sponsoredPlaces + normalPlaces
                        self.parent.showBottomSheet = true
                        
                        let region = MKCoordinateRegion(
                            center: cluster.coordinate,
                            span: MKCoordinateSpan(
                                latitudeDelta: 0.02,
                                longitudeDelta: 0.02
                            )
                        )
                        self.parent.dataManager.prioritizeRegion(region)
                    }
                } else if let place = view.annotation as? Place {
                    DispatchQueue.main.async {
                        self.parent.selectedPlaceNames = [place.name]
                        self.parent.showBottomSheet = true
                        
                        let region = MKCoordinateRegion(
                            center: place.coordinate,
                            span: MKCoordinateSpan(
                                latitudeDelta: 0.01,
                                longitudeDelta: 0.01
                            )
                        )
                        self.parent.dataManager.prioritizeRegion(region)
                    }
                }
            }
            
            mapView.deselectAnnotation(view.annotation, animated: true)
        }
    }
    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(showBottomSheet: $showBottomSheet, selectedPlaceNames: $selectedPlaceNames)
//    }
    func makeCoordinator() -> Coordinator {
            Coordinator(parent: self)
        }
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "InterestingPlace")
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "cluster")
        
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsTraffic = false
        mapView.showsBuildings = false
        
        // 隐藏地图上的兴趣点（POI）
        mapView.pointOfInterestFilter = MKPointOfInterestFilter.excludingAll
        
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.681236, longitude: 139.767125),
                      span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
        mapView.setRegion(region, animated: false)
        //mapView.addAnnotations(places)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 保持为空
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
                                distance: 100
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

