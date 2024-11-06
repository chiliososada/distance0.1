//
//  ClusterMapView.swift
//  food
//
//  Created by toyousoft on 2024/11/04.
//
import SwiftUI
import MapKit

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
            static let place = "LocationPost"
        }
        
        static let markerTintColor = UIColor(displayP3Red: 0.082, green: 0.518, blue: 0.263, alpha: 1.0)
    }
    
    // MARK: - Properties
    @StateObject private var dataManager = MapDataManager()
    @ObservedObject var viewModel: NearbyViewModel
  
//    @Binding var selectedPlaceNames: [String]
    
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
            case let post as LocationPost:
                return setupPlaceAnnotationView(for: post, in: mapView)
            default:
                return nil
            }
        }
        //
        //        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //            parent.showBottomSheet = true  // 确保底部表单显示
        //            Task {
        //                await handleAnnotationSelection(view, in: mapView)
        //            }
        //        }
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let cluster = view.annotation as? MKClusterAnnotation {
                parent.viewModel.updateSelectedPosts(from: cluster.memberAnnotations)
            } else if let post = view.annotation as? LocationPost {
                parent.viewModel.updateSelectedPosts(from: [post])
            }
            
            mapView.deselectAnnotation(view.annotation, animated: true)
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
            let currentIds = Set(currentAnnotations.compactMap { ($0 as? LocationPost)?.id })
            
            // 获取新的标注
            let newPlaces = parent.dataManager.visiblePlaces
            let newIds = Set(newPlaces.map { $0.id })
            
            // 计算需要添加和移除的标注
            let annotationsToRemove = currentAnnotations.filter { annotation in
                guard let place = annotation as? LocationPost else { return true }
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
                .compactMap { $0 as? LocationPost }
                .first { $0.isSponsored }  // 使用正确的属性
            cluster.title = sponsoredPlace?.title ?? "\(cluster.memberAnnotations.count) 个地点"
        }
        
        @MainActor
        private func handleAnnotationSelection(_ view: MKAnnotationView, in mapView: MKMapView) async {
            if let cluster = view.annotation as? MKClusterAnnotation {
                await handleClusterSelection(cluster)
            } else if let place = view.annotation as? LocationPost {
                await handlePlaceSelection(place)
            }
            
            mapView.deselectAnnotation(view.annotation, animated: true)
        }
        
        @MainActor
        private func handleClusterSelection(_ cluster: MKClusterAnnotation) async {
            // 直接从聚合标注中提取所有 LocationPost 对象
            let posts = cluster.memberAnnotations.compactMap { $0 as? LocationPost }
            
            // 更新 ViewModel 的选中状态
            parent.viewModel.updateSelectedPosts(from: cluster.memberAnnotations)
            
            // 更新地图显示区域
            let region = MKCoordinateRegion(
                center: cluster.coordinate,
                span: Constants.clusterSpan
            )
            await parent.dataManager.prioritizeRegion(region)
        }
        
        @MainActor
        private func handlePlaceSelection(_ place: LocationPost) async {
            // 更新 ViewModel 的选中状态
            parent.viewModel.updateSelectedPosts(from: [place])
            
            // 更新地图显示区域
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
