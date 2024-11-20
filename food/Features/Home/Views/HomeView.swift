import SwiftUI
import CoreLocation

struct HomeView: View {
    // MARK: - Properties
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var tabBarManager: TabBarManager
    @EnvironmentObject private var navigationManager: AppNavigationManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    // MARK: - Body
    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                iPhoneLayout
            } else {
                iPadLayout
            }
        }
    }
    
    // MARK: - Layouts
    private var iPhoneLayout: some View {
            ZStack(alignment: .leading) {
                VStack(spacing: 0) {
                    // 自定义导航栏
                    if navigationManager.selectedTab == .home && !viewModel.isNavigationBarHidden {
                        CustomNavigationBar(viewModel: viewModel)
                    }
                    
                    // 主内容
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
            .navigationBarHidden(true) // 隐藏系统导航栏
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
    
    // MARK: - Main Content
   
    private var mainContent: some View {
        VStack(spacing: 0) {
            TabView(selection: $navigationManager.selectedTab) {
                homeTabContent
                    .tag(TabRoute.home)
                
                NearbyView()
                    .tag(TabRoute.nearby)
                    .toolbar(.hidden, for: .navigationBar)
                  
                postTab
                    .tag(TabRoute.post)
                    .toolbar(.hidden, for: .navigationBar)
                
                ChatRoomListView()
                    .tag(TabRoute.chat)
                    .toolbar(.hidden, for: .navigationBar)
                
                ProfileView()
                    .tag(TabRoute.profile)
                    .toolbar(.hidden, for: .navigationBar)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !tabBarManager.isNavigatingInTab {
                TabBar(selectedTab: $navigationManager.selectedTab)
                    .transition(.move(edge: .bottom))
                    .frame(height: 35)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
    
    private var homeTabContent: some View {
        VStack(spacing: 1) {
            SearchAndFilterView(search: $viewModel.search)
                .padding(.bottom, 8)
                .padding(.top, 2)
            TabStateScrollView(
                axis: .vertical,
                showsIndicator: false,
                tabState: $viewModel.tabState,
                isNavigationBarHidden: $viewModel.isNavigationBarHidden
            ) {
                HomeTabContentView()
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

// MARK: - Helper Functions
func getRect() -> CGRect {
    UIScreen.main.bounds
}

// MARK: - Previews
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(GlobalManagers.preview.tabBarManager)
            .environmentObject(GlobalManagers.preview.navigationManager)
            .environmentObject(GlobalManagers.preview.locationManager)
            .environmentObject(GlobalManagers.preview.authManager)
    }
}
struct TabBar: View {
    @Binding var selectedTab: TabRoute
    private let tabHeight: CGFloat = 40  // 定义一个底部固定的高度常量
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                TabButton(
                    title: "",
                    icon: "house.fill",
                    isSelected: selectedTab == .home
                ) {
                    selectedTab = .home
                }
                
                TabButton(
                    title: "",
                    icon: "location.fill",
                    isSelected: selectedTab == .nearby
                ) {
                    selectedTab = .nearby
                }
                
                TabButton(
                    title: "",
                    icon: "plus.circle.fill",
                    isSelected: selectedTab == .post
                ) {
                    selectedTab = .post
                }
                
                TabButton(
                    title: "",
                    icon: "message.fill",
                    isSelected: selectedTab == .chat
                ) {
                    selectedTab = .chat
                }
                
                TabButton(
                    title: "",
                    icon: "person.fill",
                    isSelected: selectedTab == .profile
                ) {
                    selectedTab = .profile
                }
            }
            .padding(.horizontal)
            .padding(.top)
            .frame(height: tabHeight)  // 使用固定高度
        }
        .background(
            Color.white
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {  // 增加间距
                Image(systemName: icon)
                    .font(.system(size: 25))  // 适当调整图标大小
                    .frame(height: 38)  // 给图标一个合适的高度
                Text(title)
                    .font(.caption2)
            }
            .foregroundColor(isSelected ? .black : .gray)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
    }
}

#Preview {
    TabBar(selectedTab: .constant(.home))
}
// 自定义导航栏组件
struct CustomNavigationBar: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        HStack {
            // 左侧菜单按钮
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
            
            // 右侧位置按钮
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
