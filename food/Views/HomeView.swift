import SwiftUI
import CoreLocation

// MARK: - HomeViewModel
final class HomeViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var isShowingPostInputView = false
    @Published var isViewTabBarHidden = false
    @Published var tabState: Visibility = .visible
    @Published var showMenu = false
    @Published var offset: CGFloat = 0
    @Published var lastStoredOffset: CGFloat = 0
    @Published var search: String = ""
    @Published var isNavigationBarHidden = false
    @Published var userLocationText = ""
    @Published var locationManager = LocationManager.shared
    
    private var isInteracting = false
    private var previousLocation: CLLocation?
    
    let sideBarWidth: CGFloat = UIScreen.main.bounds.width * 0.7
    
    var isHomeTab: Bool {
          selectedTab == 0
      }
    
    // MARK: - Menu Control Methods
    func closeMenu() {
        guard !isInteracting else { return }
        isInteracting = true
        
        withAnimation {
            showMenu = false
            offset = 0
        }
        
        resetInteractionState()
    }
    
    func toggleMenu() {
        guard !isInteracting else { return }
        isInteracting = true
        
        withAnimation {
            showMenu.toggle()
        }
        
        resetInteractionState()
    }
    
    private func resetInteractionState() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isInteracting = false
        }
    }
    
    // MARK: - Gesture Handlers
    func handleGestureChange(translation: CGFloat) {
          guard isHomeTab else { return }
          let sideBarWidth = UIScreen.main.bounds.width - 90
          offset = (translation != 0) ?
              min(translation + lastStoredOffset, sideBarWidth) :
              offset
    }
    
    func handleGestureEnd(translation: CGFloat) {
        guard isHomeTab else { return }
        let sideBarWidth = UIScreen.main.bounds.width - 90
        
        withAnimation {
            if translation > 0 {
                if translation > (sideBarWidth / 2) {
                    offset = sideBarWidth
                    showMenu = true
                } else {
                    if offset == sideBarWidth { return }
                    offset = 0
                    showMenu = false
                }
            } else {
                if -translation > (sideBarWidth / 2) {
                    offset = 0
                    showMenu = false
                } else {
                    if offset == 0 || !showMenu { return }
                    offset = sideBarWidth
                    showMenu = true
                }
            }
        }
        lastStoredOffset = offset
    }
    
    // MARK: - Location Methods
    func updateLocationText() {
        guard let location = locationManager.userLocation else { return }
        
        if let previous = previousLocation, location.distance(from: previous) < 100 {
            return
        }
        
        previousLocation = location
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self,
                  let placemark = placemarks?.first else { return }
            
            var components: [String] = []
            
            if let subLocality = placemark.subLocality, !subLocality.isEmpty {
                components.append(subLocality)
            }
            if let locality = placemark.locality, !locality.isEmpty {
                components.append(locality)
            }
            if let area = placemark.administrativeArea, !area.isEmpty {
                components.append(area)
            }
            
            DispatchQueue.main.async {
                self.userLocationText = components.joined(separator: ", ")
            }
        }
    }
}

// MARK: - HomeView
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var tabBarManager: TabBarManager
    @GestureState private var gestureOffset: CGFloat = 0
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
            Group {
                if horizontalSizeClass == .compact {
                    // iPhone 布局保持不变
                    NavigationView {
                        ZStack {
                            HStack(spacing: 0) {
                                SideMenu(showMenu: $viewModel.showMenu)
                                VStack(spacing: 0) {
                                    tabViewContent
                                        .navigationBarHidden(true)
                                }
                                .frame(width: getRect().width)
                                .overlay(menuOverlay)
                            }
                            .frame(width: getRect().width + viewModel.sideBarWidth)
                            .offset(x: -viewModel.sideBarWidth / 2)
                            .offset(x: viewModel.offset > 0 ? viewModel.offset : 0)
                            .gesture(menuDragGesture)
                        }
                        .navigationViewStyle(StackNavigationViewStyle())
                        .animation(.easeOut, value: viewModel.offset == 0)
                        .onChange(of: viewModel.showMenu) {
                            updateMenuState()
                        }
                        .ignoresSafeArea(edges: .bottom)
                    }
                } else {
                    // iPad 布局优化
                    NavigationSplitView {
                        SideMenu(showMenu: $viewModel.showMenu)
                            .frame(minWidth: 320, idealWidth: viewModel.sideBarWidth, maxWidth: 400)
                            .background(Color.white)
                    } detail: {
                        VStack(spacing: 0) {
                            tabViewContent
                                .navigationBarHidden(viewModel.isNavigationBarHidden)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white)
                        .ignoresSafeArea(edges: .bottom)
                    }
                    .navigationSplitViewStyle(.balanced)
                }
            }
        }

    private var menuOverlay: some View {
        Rectangle()
            .fill(Color.primary.opacity(Double(viewModel.offset / viewModel.sideBarWidth / 5)))
            .ignoresSafeArea(.container, edges: .vertical)
            .onTapGesture { viewModel.closeMenu() }
    }
    
    private var menuDragGesture: some Gesture {
        DragGesture()
            .updating($gestureOffset) { value, state, _ in
                if viewModel.isHomeTab {
                    state = value.translation.width
                }
            }
            .onChanged { _ in
                viewModel.handleGestureChange(translation: gestureOffset)
            }
            .onEnded { value in
                viewModel.handleGestureEnd(translation: value.translation.width)
            }
    }
    
    private func updateMenuState() {
        guard viewModel.isHomeTab else { return }
        
        if viewModel.showMenu && viewModel.offset == 0 {
            viewModel.offset = viewModel.sideBarWidth
            viewModel.lastStoredOffset = viewModel.offset
        }
        
        if !viewModel.showMenu && viewModel.offset == viewModel.sideBarWidth {
            viewModel.offset = 0
            viewModel.lastStoredOffset = 0
        }
    }
    
    // MARK: - Tab Content
    private var tabViewContent: some View {
        VStack {
            TabView(selection: $viewModel.selectedTab) {
                homeTab
                    .tabItem { Image(systemName: "house.fill") }
                    .tag(0)
                    
                NearbyView()
                    .tabItem { Image(systemName: "location.fill") }
                    .tag(1)
                
                plusTab
                    .tabItem { Image(systemName: "plus.circle.fill") }
                    .tag(2)
                
                ChatRoomListView()
                    .tabItem { Image(systemName: "message.fill") }
                    .tag(3)
                
                ProfileView()
                    .tabItem { Image(systemName: "person.fill") }
                    .tag(4)
            }
            .accentColor(.black)
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    private var homeTab: some View {
        NavigationStack {
            SearchAndFilterView(search: $viewModel.search)
            TabStateScrollView(
                axis: .vertical,
                showsIndicator: false,
                tabState: $viewModel.tabState,
                isNavigationBarHidden: $viewModel.isNavigationBarHidden
            ) {
                HomeTabContentView()
                    .navigationBarHidden(viewModel.isNavigationBarHidden)
                    .navigationBarItems(
                        leading: leadingNavBarItem,
                        trailing: trailingNavBarItem
                    )
                    
            }
            .toolbar(
                (viewModel.tabState == .hidden || tabBarManager.isViewTabBarHidden) ? .hidden : .visible,
                for: .tabBar
            )
            .animation(.easeInOut(duration: 0.2), value: viewModel.tabState == .hidden)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .tabItem { Image(systemName: "house.fill") }
        .tag(0)
    }
    
    private var plusTab: some View {
        Text("")
            .tabItem { Image(systemName: "plus.circle.fill") }
            .tag(2)
            .onAppear { viewModel.isShowingPostInputView = true }
            .fullScreenCover(isPresented: $viewModel.isShowingPostInputView) {
                PostInputView(
                    isPresented: $viewModel.isShowingPostInputView,
                    selectedTab: $viewModel.selectedTab
                )
            }
    }
    
    private var leadingNavBarItem: some View {
        Button(action: viewModel.toggleMenu) {
            Image(uiImage: #imageLiteral(resourceName: "menu"))
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.black)
        }
    }
    
    private var trailingNavBarItem: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.black)
                Text(viewModel.userLocationText)
                    .font(.caption2)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(TabBarManager())
    }
}

// MARK: - Helper
func getRect() -> CGRect {
    return UIScreen.main.bounds
}
