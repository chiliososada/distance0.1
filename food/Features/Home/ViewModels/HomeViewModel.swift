import SwiftUI
import CoreLocation
import Combine

final class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedTab = 0
    @Published var isShowingPostInputView = false
    @Published var isViewTabBarHidden = false
   
    @Published var offset: CGFloat = 0
    @Published var lastStoredOffset: CGFloat = 0
    @Published var search: String = ""
    @Published var userLocationText: String = "Loading..."
   
    @Published var tabState: Visibility = .visible {
        didSet {
            print("Tab state changed to: \(tabState)")
            // 不在这里设置 isNavigationBarHidden，让 View 层负责这个逻辑
        }
    }
      
    @Published var isNavigationBarHidden: Bool = false {
        didSet {
            print("Navigation bar hidden state changed to: \(isNavigationBarHidden)")
        }
    }
      
    @Published var showMenu: Bool = false {
        didSet {
            print("Menu state changed to: \(showMenu)")
        }
    }

    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var isInteracting = false
    private let locationManager: LocationManager
    
    // MARK: - Constants
    let sideBarWidth: CGFloat = UIScreen.main.bounds.width * 0.7
    
    // MARK: - Computed Properties
    var isHomeTab: Bool {
        selectedTab == 0
    }
    
    // MARK: - Initialization
    init() {
        print("HomeViewModel initialized")
        self.locationManager = GlobalManagers.shared.locationManager
        setupSubscriptions()
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
            
        // 移除对 tabState 的订阅，因为我们在 View 层处理这个逻辑
            
        $showMenu
            .sink { [weak self] shown in
                self?.handleMenuStateChange(shown)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - State Handlers
    private func handleMenuStateChange(_ shown: Bool) {
        guard isHomeTab else { return }
        
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
    
    // MARK: - Menu Control Methods
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

// MARK: - Preview Helper
#if DEBUG
extension HomeViewModel {
    static func preview() -> HomeViewModel {
        let viewModel = HomeViewModel()
        viewModel.userLocationText = "東京都 葛飾区 立石"
        return viewModel
    }
}
#endif
