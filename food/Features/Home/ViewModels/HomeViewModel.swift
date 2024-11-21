import SwiftUI
import CoreLocation
import Combine

final class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedTab = 0
    @Published var isShowingPostInputView = false
    @Published var search: String = ""
    @Published var posts: [LocationPost] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published var showMenu: Bool = false {
        didSet {
            print("Menu state changed to: \(showMenu)")
            handleMenuStateChange(showMenu)
        }
    }
    @Published var isNavigatingInTab: Bool = false
    @Published var isViewTabBarHidden: Bool = false
    
    // MARK: - Properties
    var offset: CGFloat = 0
    var lastStoredOffset: CGFloat = 0
    var userLocationText: String = "Loading..."
    var tabState: Visibility = .visible
    var isNavigationBarHidden: Bool = false
    let sideBarWidth: CGFloat = UIScreen.main.bounds.width * 0.7
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var isInteracting = false
    private let locationManager: LocationManager
    private let locationService: PostLocationService
    private let debounceInterval: TimeInterval = 0.3
    
    // MARK: - Initialization
    init() {
        print("HomeViewModel initialized")
        self.locationManager = GlobalManagers.shared.locationManager
        self.locationService = PostLocationService.shared
        setupSubscriptions()
        setupSearchBinding()
        
        Task {
            await loadInitialPosts()
        }
    }
    
    // MARK: - Setup Methods
    private func setupSubscriptions() {
        locationManager.addressSubject
            .receive(on: DispatchQueue.main)
            .assign(to: \.userLocationText, on: self)
            .store(in: &cancellables)
        
        locationManager.$authorizationStatus
            .sink { [weak self] status in
                if status == .authorizedWhenInUse || status == .authorizedAlways {
                    self?.locationManager.startUpdatingLocation()
                }
            }
            .store(in: &cancellables)
        
        locationManager.$isLocationServicesEnabled
            .filter { !$0 }
            .sink { [weak self] _ in
                self?.userLocationText = "Location services disabled"
            }
            .store(in: &cancellables)
        
        $showMenu
            .sink { [weak self] shown in
                self?.handleMenuStateChange(shown)
            }
            .store(in: &cancellables)
    }
    
    private func setupSearchBinding() {
        $search
            .debounce(for: .seconds(debounceInterval), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                print("Search text changed - \(searchText)")
                Task { [weak self] in
                    await self?.filterPosts()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Posts Methods
    @MainActor
    func loadInitialPosts() async {
        await fetchPosts()
    }
    
    @MainActor
    func refreshPosts() async {
        await fetchPosts()
    }
    
    @MainActor
    private func fetchPosts() async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await locationService.fetchPosts(searchText: search)
            self.posts = locationService.filteredPosts
        } catch {
            self.error = error
        }
    }

    @MainActor
    func filterPosts(by category: String? = nil, tags: Set<String>? = nil) async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await locationService.fetchPosts(searchText: search)
            self.posts = locationService.filteredPosts.filter { post in
                var matches = true
                
                if let category = category {
                    matches = matches && post.tags.contains(category)
                }
                
                if let tags = tags, !tags.isEmpty {
                    matches = matches && !Set(post.tags).intersection(tags).isEmpty
                }
                
                return matches
            }
        } catch {
            self.error = error
        }
    }
    
    // MARK: - TabBar Methods
    func hideTabBar() {
        isNavigatingInTab = true
    }
    
    func showTabBar() {
        isNavigatingInTab = false
        isViewTabBarHidden = false
    }
    
    func setTabNavigationState(_ isNavigating: Bool) {
        isNavigatingInTab = isNavigating
    }
    
    func resetTabState() {
        isNavigatingInTab = false
        isViewTabBarHidden = false
    }
    
    // MARK: - Menu Methods
    private func handleMenuStateChange(_ shown: Bool) {
        guard selectedTab == 0 else { return }
        
        withAnimation(.spring()) {
            if shown && offset == 0 {
                offset = sideBarWidth
                lastStoredOffset = offset
            } else if !shown && offset == sideBarWidth {
                offset = 0
                lastStoredOffset = 0
            }
        }
    }
    
    func toggleMenu() {
        guard !isInteracting else { return }
        isInteracting = true
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showMenu.toggle()
        }
        
        resetInteractionState()
    }
    
    func closeMenu() {
        guard !isInteracting else { return }
        isInteracting = true
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showMenu = false
            offset = 0
        }
        
        resetInteractionState()
    }
    
    private func resetInteractionState() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isInteracting = false
        }
    }
    
    // MARK: - Location Methods
    func requestLocationUpdate() {
        locationManager.requestLocationPermissionIfNeeded()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Cleanup
    deinit {
        print("HomeViewModel deinitialized")
        cancellables.removeAll()
    }
}

#if DEBUG
extension HomeViewModel {
    static func preview() -> HomeViewModel {
        let viewModel = HomeViewModel()
        viewModel.userLocationText = "東京都 葛飾区 立石"
        return viewModel
    }
}
#endif
