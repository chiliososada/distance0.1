//
//  HomeTabViewModel.swift
//  food
//
//  Created by toyousoft on 2024/11/24.
//

import SwiftUI
import Combine

// MARK: - ViewModel
final class HomeTabViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var search: String = ""
    @Published var posts: [LocationPost] = []
    @Published private(set) var isShowingMenu: Bool = false // 将 set 设为私有
    @Published var userLocationText: String = "Loading..."
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let locationManager: LocationManager
    private let postService: PostLocationService
    private let debounceInterval: TimeInterval = 0.3
    
    // MARK: - Initialization
    init(
        locationManager: LocationManager = .shared,
        postService: PostLocationService = .shared
    ) {
        self.locationManager = locationManager
        self.postService = postService
        
        setupSubscriptions()
        setupSearchBinding()
        
        Task {
            await loadInitialPosts()
        }
    }
    
    // MARK: - Setup Methods
    private func setupSubscriptions() {
        // Location updates subscription
        locationManager.addressSubject
            .receive(on: DispatchQueue.main)
            .assign(to: \.userLocationText, on: self)
            .store(in: &cancellables)
        
        // Location authorization subscription
        locationManager.$authorizationStatus
            .sink { [weak self] status in
                if status == .authorizedWhenInUse || status == .authorizedAlways {
                    self?.locationManager.startUpdatingLocation()
                }
            }
            .store(in: &cancellables)
        
        // Location services status subscription
        locationManager.$isLocationServicesEnabled
            .filter { !$0 }
            .sink { [weak self] _ in
                self?.userLocationText = "Location services disabled"
            }
            .store(in: &cancellables)
    }
    
    private func setupSearchBinding() {
        $search
            .debounce(for: .seconds(debounceInterval), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                Task { [weak self] in
                    await self?.filterPosts()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    @MainActor
    func loadInitialPosts() async {
        await fetchPosts()
    }
    
    @MainActor
    func refreshPosts() async {
        await fetchPosts()
    }
    
    // MARK: - Private Methods
    @MainActor
    private func fetchPosts() async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await postService.fetchPosts(searchText: search)
            self.posts = postService.filteredPosts
        } catch {
            self.error = error
        }
    }
    
    @MainActor
    private func filterPosts() async {
        await fetchPosts()
    }
    
    // MARK: - Cleanup
    deinit {
        cancellables.removeAll()
    }
}

