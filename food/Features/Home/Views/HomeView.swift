import SwiftUI
import CoreLocation

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var navigationManager: AppNavigationManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private let homeViewId = "HomeView"
    
    init() {
        print("HomeView init")
    }
    
    var body: some View {
        let _ = Self._printChanges()
        Group {
            if horizontalSizeClass == .compact {
                iPhoneLayout
            } else {
                iPadLayout
            }
        }.id(homeViewId)
    }
    
    private var iPhoneLayout: some View {
        ZStack(alignment: .leading) {
            VStack(spacing: 0) {
                if navigationManager.selectedTab == .home && !viewModel.isNavigationBarHidden {
                    CustomNavigationBar(viewModel: viewModel)
                }
                mainContent
            }
            .background(Color.white)
            .frame(width: getRect().width)
            .overlay {
                if viewModel.showMenu {
                    Color.black
                        .opacity(0.2)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                viewModel.closeMenu()
                            }
                        }
                }
            }
            .offset(x: viewModel.showMenu ? viewModel.sideBarWidth : 0)
            
            if viewModel.showMenu {
                SideMenu(showMenu: $viewModel.showMenu)
                    .frame(width: viewModel.sideBarWidth)
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.easeOut(duration: 0.3), value: viewModel.showMenu)
        .navigationBarHidden(true)
        .sheet(isPresented: $navigationManager.isPresentingSheet) {
            if let route = navigationManager.presentedSheet {
                sheetView(for: route)
            }
        }
    }
    
    private var iPadLayout: some View {
        NavigationSplitView {
            SideMenu(showMenu: $viewModel.showMenu)
                .frame(minWidth: 320, idealWidth: viewModel.sideBarWidth, maxWidth: 400)
                .background(Color.white)
        } detail: {
            VStack(spacing: 0) {
                if navigationManager.selectedTab == .home && !viewModel.isNavigationBarHidden {
                    CustomNavigationBar(viewModel: viewModel)
                }
                mainContent
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    private var mainContent: some View {
        TabView(selection: $navigationManager.selectedTab) {
            homeTabContent
                .tag(TabRoute.home)
                .tabItem {
                    Image(systemName: "house.fill")
                }
            
            NearbyView()
                .tag(TabRoute.nearby)
                .toolbar(.hidden, for: .navigationBar)
                .tabItem {
                    Image(systemName: "location.fill")
                }
            
            postTab
                .tag(TabRoute.post)
                .toolbar(.hidden, for: .navigationBar)
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                }
            
            ChatRoomListView()
                .tag(TabRoute.chat)
                .toolbar(.hidden, for: .navigationBar)
                .tabItem {
                    Image(systemName: "message.fill")
                }
            
            ProfileView()
                .tag(TabRoute.profile)
                .toolbar(.hidden, for: .navigationBar)
                .tabItem {
                    Image(systemName: "person.fill")
                }
        }
    }
    
    private var homeTabContent: some View {
        VStack(spacing: 1) {
            SearchAndFilterView(search: $viewModel.search)
                .padding(.bottom, 8)
                .padding(.top, 2)
            
            ScrollView {
                LazyVStack(spacing: 16, pinnedViews: []) {
                    ForEach(viewModel.posts) { post in
                        LocationPostButton(post: post) {
                            navigationManager.navigate(to: .postDetail(post: post))
                        }
                        .id(post.id)
                    }
                }
                .padding()
            }
        }
    }
    
    private var postTab: some View {
        Color.clear
            .onAppear { viewModel.isShowingPostInputView = true }
            .fullScreenCover(isPresented: $viewModel.isShowingPostInputView) {
                PostInputView(
                    isPresented: $viewModel.isShowingPostInputView,
                    selectedTab: $navigationManager.selectedTab
                )
            }
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

func getRect() -> CGRect {
    UIScreen.main.bounds
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(GlobalManagers.preview.navigationManager)
            .environmentObject(GlobalManagers.preview.locationManager)
            .environmentObject(GlobalManagers.preview.authManager)
    }
}

struct CustomNavigationBar: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        HStack {
            Button(action: {
                print("Menu button tapped")
                viewModel.toggleMenu()
            }) {
                Image(uiImage: #imageLiteral(resourceName: "menu"))
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Button(action: {
                print("Location button tapped")
            }) {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                    Text(viewModel.userLocationText)
                        .font(.caption2)
                        .lineLimit(1)
                }
                .foregroundColor(.black)
            }
        }
        .padding(.horizontal)
        .frame(height: 44)
        .background(Color.white)
    }
}
