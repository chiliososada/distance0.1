import SwiftUI
import MapKit


extension CLLocationCoordinate2D {
    static let parking = CLLocationCoordinate2D(latitude: 35.765, longitude: 139.8485)  // 替换为你的坐标
    static let parking1 = CLLocationCoordinate2D(latitude: 35.764, longitude: 139.8486)  // 替换为你的坐标
}
extension MKCoordinateRegion {
    static let boston = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 42.360256,
            longitude: -71.057279
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.1,
            longitudeDelta: 0.1
        )
    )

    static let northShore = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 42.547408,
            longitude: -70.870085
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.5,
            longitudeDelta: 0.5
        )
    )
}
// 自定义的 Place 模型
class Place: NSObject, MKAnnotation {
    let name: String
    let coordinate: CLLocationCoordinate2D
    let image: String
    let sponsored: Bool
    
    var title: String? { name }
    
    init(name: String, latitude: Double, longitude: Double, sponsored: Bool = false) {
        self.name = name
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.image = "placeholder"
        self.sponsored = sponsored
        super.init()
    }
}


// 自定义的 MapView 使用 MKMapView
struct ClusterMapView: UIViewRepresentable {
    let places: [Place]
    @Binding var showBottomSheet: Bool
    @Binding var selectedPlaceNames: [String]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "InterestingPlace")
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "cluster")
        
        // 启用聚合
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
       
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsTraffic = false
        mapView.showsBuildings = false
       /* mapView.showsPointsOfInterest = false */ // 显示兴趣点
        // 设置地图初始区域
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.738361, longitude: 139.848861),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
        mapView.setRegion(region, animated: false)
        // 添加标注
        mapView.addAnnotations(places)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }
    
    func makeCoordinator() -> MapCoordinator {
        return MapCoordinator(showBottomSheet: $showBottomSheet, selectedPlaceNames: $selectedPlaceNames)
    }
    
    // 自定义 MapCoordinator 处理聚合
    class MapCoordinator: NSObject, MKMapViewDelegate {
        @Binding var showBottomSheet: Bool
        @Binding var selectedPlaceNames: [String]
        
        init(showBottomSheet: Binding<Bool>, selectedPlaceNames: Binding<[String]>) {
            _showBottomSheet = showBottomSheet
            _selectedPlaceNames = selectedPlaceNames
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            switch annotation {
            case let cluster as MKClusterAnnotation:
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "cluster") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "cluster")
                annotationView.markerTintColor = UIColor(displayP3Red: 0.082, green: 0.518, blue: 0.263, alpha: 1.0)
                
                // 查找 sponsored 地点并优先显示其名称
                for clusterAnnotation in cluster.memberAnnotations {
                    if let place = clusterAnnotation as? Place, place.sponsored {
                        cluster.title = place.name
                        break
                    }
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
                annotationView.detailCalloutAccessoryView = UIImage(named: placeAnnotation.image).map(UIImageView.init)
                return annotationView
                
            default:
                return nil
            }
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let cluster = view.annotation as? MKClusterAnnotation {
                var placeNames: [String] = []
                for member in cluster.memberAnnotations {
                    if let place = member as? Place {
                        placeNames.append(place.name)
                    }
                }
                
                // 更新状态并显示 BottomMenuView
                selectedPlaceNames = placeNames
                showBottomSheet = true
            }
            // 检查是否是普通的 Place 标注
               else if let place = view.annotation as? Place {
                   // 更新状态并显示 BottomMenuView，placeNames 只包含一个地方
                   selectedPlaceNames = [place.name]
                   showBottomSheet = true
               }
        }
    }
}


struct NearbyView: View {
    // 创建聚合的测试数据
    let places: [Place] = {
        var places: [Place] = []
        let baseLatitude = 35.738361  // 京成立石地铁站的纬度
        let baseLongitude = 139.848861  // 京成立石地铁站的经度
        
        // 创建多个地点数据
        for i in 0..<10 {
            for j in 0..<10 {
                let latitude = baseLatitude + Double(i) * 0.0005
                let longitude = baseLongitude + Double(j) * 0.0005
                places.append(Place(
                    name: "Location \(i * 10 + j)",
                    latitude: latitude,
                    longitude: longitude
                ))
            }
        }
        return places
    }()
    
    @State private var position: MapCameraPosition = .automatic
    @State private var searchResult: [MKMapItem] = []
    @State private var visibleRegion: MKCoordinateRegion?
    
    // 用于显示 BottomMenuView 的状态和选中的 MKClusterAnnotation 数据
    @State private var showBottomSheet = false
    @State private var selectedPlaceNames: [String] = []
    @State private var search: String = ""
    @State private var showFilterView = false  // 控制弹出视图显示
    var body: some View {
        ZStack {
            // 地图放在底部，只忽略顶部和左右的安全区域
            ClusterMapView(places: places, showBottomSheet: $showBottomSheet, selectedPlaceNames: $selectedPlaceNames)
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
    var placeNames: [String] // 用于接收 MKClusterAnnotation 的名称列表

    var body: some View {
        VStack {
            // 显示选中的地点数量
                       Text("Selected Places (\(placeNames.count))")
                           .font(.headline)
                           .padding()


            // 使用 ForEach 迭代 placeNames 列表，并将每个名称显示为卡片标题
            ScrollView {
                ForEach(placeNames, id: \.self) { name in
                    RecommendedRecipeCardView(
                        image: UIImage(named: "fresh_recipe_1") ?? UIImage(), // 可根据实际需求调整图片
                        title: name, // 动态将 placeNames 的值作为卡片的标题
                        onTap: {},
                        busynessLevel: Color.red // 可根据需求调整
                    )
                    .padding(.vertical, 5)
                }
            }
        }
        .padding()
    }
}
