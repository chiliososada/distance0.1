import SwiftUI
import MapKit
import Combine

@MainActor
class NearbyViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var places: [Place] = []
    @Published var selectedPlaceNames: [String] = []
    @Published var showBottomSheet: Bool = false
    @Published var showFilterView: Bool = false  // Add this property
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
    
    // MARK: - Private Methods
    private func setupBindings() {
        mapDataManager.$visiblePlaces
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newPlaces in
                self?.places = newPlaces
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
    func loadPlaces(in region: MKCoordinateRegion) {
        Task {
            do {
                print("1. Loading places in region: \(region) ...")
                await mapDataManager.loadPlaces(in: region)
            } catch {
                self.error = error
            }
        }
    }
    
    func cleanupInvisibleRegions(currentRegion: MKCoordinateRegion) {
        Task {
            do {
                await mapDataManager.cleanupInvisibleRegions(currentRegion: currentRegion)
            } catch {
                self.error = error
            }
        }
    }
    
    func prioritizeRegion(_ region: MKCoordinateRegion) {
        Task {
            do {
                await mapDataManager.prioritizeRegion(region)
            } catch {
                self.error = error
            }
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
