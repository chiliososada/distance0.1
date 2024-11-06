import SwiftUI
import MapKit
import Combine

@MainActor
class NearbyViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedPosts: [LocationPost] = []
       @Published var showBottomSheet: Bool = false
       @Published var showFilterView: Bool = false
       @Published private(set) var isLoading: Bool = false
       @Published private(set) var error: Error?
       @Published var search: String = ""
    
    // MARK: - Dependencies
    private let mapDataManager: MapDataManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(mapDataManager: MapDataManager = MapDataManager()) {
        self.mapDataManager = mapDataManager
        setupBindings()
    }
    
    // MARK: - Public Methods
      func updateSelectedPosts(from annotations: [MKAnnotation]) {
          // 从注解中提取 LocationPost 对象
          let posts = annotations.compactMap { annotation -> [LocationPost] in
              if let post = annotation as? LocationPost {
                  return [post]
              } else if let cluster = annotation as? MKClusterAnnotation {
                  // 对于聚合标注，提取所有成员
                  return cluster.memberAnnotations.compactMap { $0 as? LocationPost }
              }
              return []
          }.flatMap { $0 } // 展平数组
          
          selectedPosts = Array(posts)
          showBottomSheet = !selectedPosts.isEmpty
      }
      
    // MARK: - Private Methods
    private func setupBindings() {
        mapDataManager.$visiblePlaces
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newPlaces in
                self?.selectedPosts = newPlaces
            }
            .store(in: &cancellables)
        
        mapDataManager.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                self?.isLoading = loading
            }
            .store(in: &cancellables)
        
        mapDataManager.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newError in
                self?.error = newError
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
//    func loadPlaces(in region: MKCoordinateRegion) {
//        Task {
//            do {
//                print("1. Loading places in region: \(region) ...")
//                await mapDataManager.loadPlaces(in: region)
//            } catch {
//                self.error = error
//            }
//        }
//    }
    func loadPlaces(in region: MKCoordinateRegion) {
           Task {
               await mapDataManager.loadPlaces(in: region)
           }
       }
    func cleanupInvisibleRegions(currentRegion: MKCoordinateRegion) {
           Task {
               await mapDataManager.cleanupInvisibleRegions(currentRegion: currentRegion)
           }
       }
    
    func prioritizeRegion(_ region: MKCoordinateRegion) {
        Task {
                await mapDataManager.prioritizeRegion(region)
        }
    }
    
    // MARK: - Button Action Handlers
    func handleHotspotsTap() {
        // Implement the functionality for hotspots tap
    }
    
    func handleLocationTap() {
        // Implement the functionality for location tap
    }
    
    func handleBuildingsTap() {
        // Implement the functionality for buildings tap
    }
    
    func handleWavesTap() {
        // Implement the functionality for waves tap
    }
}
