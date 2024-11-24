import SwiftUI
import CoreLocation

// MARK: - HomeView
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var navigationManager: AppNavigationManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        ZStack {
            if horizontalSizeClass == .compact {
                LazyView(TabContainerView())
                    .disabled(navigationManager.isShowingMenu)
            } else {
                LazyView(iPadLayout)
            }
            
            if navigationManager.isShowingMenu {
                MenuOverlay(
                    isShowing: .init(
                        get: { navigationManager.isShowingMenu },
                        set: { navigationManager.isShowingMenu = $0 }
                    ),
                    onClose: navigationManager.closeMenu
                )
            }
        }
        .sheet(isPresented: $navigationManager.isPresentingSheet) {
            if let route = navigationManager.presentedSheet {
                sheetView(for: route)
            }
        }
    }
    
    private var iPadLayout: some View {
        NavigationSplitView {
            SideMenu(showMenu: .constant(true))
                .frame(minWidth: 320, idealWidth: UIScreen.main.bounds.width * 0.7, maxWidth: 400)
                .background(Color.white)
        } detail: {
            LazyView(TabContainerView())
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    @ViewBuilder
    private func sheetView(for route: AppRoute) -> some View {
        switch route {
        case .postInput:
            PostInputView(
                isPresented: $navigationManager.isPresentingSheet,
                selectedTab: .constant(.home)
            )
        case .searchFilter:
            SearchFilterView(showFilterView: $navigationManager.isPresentingSheet)
        default:
            EmptyView()
        }
    }
}

// MARK: - TabContainerView
struct TabContainerView: View {
    @EnvironmentObject private var navigationManager: AppNavigationManager
    
    var body: some View {
        TabView(selection: $navigationManager.selectedTab) {
            LazyView(HomeTabView(onMenuTap: navigationManager.toggleMenu))
                .tag(TabRoute.home)
                .tabItem {
                    Image(systemName: "house.fill")
                }
            
            LazyView(NearbyView())
                .tag(TabRoute.nearby)
                .toolbar(.hidden, for: .navigationBar)
                .tabItem {
                    Image(systemName: "location.fill")
                }
            
            LazyView(PostTabContainer())
                .tag(TabRoute.post)
                .toolbar(.hidden, for: .navigationBar)
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                }
            
            LazyView(ChatRoomListView())
                .tag(TabRoute.chat)
                .toolbar(.hidden, for: .navigationBar)
                .tabItem {
                    Image(systemName: "message.fill")
                }
            
            LazyView(ProfileView())
                .tag(TabRoute.profile)
                .toolbar(.hidden, for: .navigationBar)
                .tabItem {
                    Image(systemName: "person.fill")
                }
        }
    }
}

// MARK: - PostTabContainer
struct PostTabContainer: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var navigationManager: AppNavigationManager
    
    var body: some View {
        Color.clear
            .onAppear { viewModel.isShowingPostInputView = true }
            .fullScreenCover(isPresented: $viewModel.isShowingPostInputView) {
                PostInputView(
                    isPresented: $viewModel.isShowingPostInputView,
                    selectedTab: $navigationManager.selectedTab
                )
            }
    }
}

// MARK: - MenuOverlay
struct MenuOverlay: View {
    @Binding var isShowing: Bool
    let onClose: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            Color.black
                .opacity(isShowing ? 0.2 : 0)
                .ignoresSafeArea(edges: .all)
                .onTapGesture(perform: onClose)
                .overlay(
                    HStack(spacing: 0) {
                        SideMenu(showMenu: $isShowing)
                            .frame(width: min(geometry.size.width * 0.7, 300))
                            .background(Color.white)
                            .offset(x: isShowing ? 0 : -300)
                        Spacer()
                    }
                )
        }
        .animation(.spring(), value: isShowing)
        .allowsHitTesting(isShowing)
    }
}

// MARK: - LazyView
struct LazyView<Content: View>: View {
    let build: () -> Content
    
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    
    var body: Content {
        build()
    }
}

// MARK: - Preview Provider
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(GlobalManagers.preview.navigationManager)
            .environmentObject(GlobalManagers.preview.locationManager)
            .environmentObject(GlobalManagers.preview.authManager)
    }
}

func getRect() -> CGRect {
    UIScreen.main.bounds
}
