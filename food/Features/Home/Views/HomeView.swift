import SwiftUI
import CoreLocation

// MARK: - HomeView
/// 主页视图，负责展示应用程序的主要界面
struct HomeView: View {
    // MARK: - 属性
    // 初始化方法，打印调试信息
    init() {
        print("HomeView")
    }
    
    // 视图模型
    @StateObject private var viewModel = HomeViewModel()
    // 环境对象，用于管理标签栏状态
    @EnvironmentObject var tabBarManager: TabBarManager
    // 环境对象，用于管理导航状态
    @EnvironmentObject var navigationManager: AppNavigationManager
    // 获取设备横向尺寸类别，用于适配iPad布局
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // MARK: - 视图主体
    var body: some View {
        // 根据设备尺寸选择不同布局
        Group {
            if horizontalSizeClass == .compact {
                mainNavigationView  // iPhone布局
            } else {
                iPadLayoutView     // iPad布局
            }
        }
    }
 
    // MARK: - 私有视图组件
    /// iPhone设备的主导航视图
    private var mainNavigationView: some View {
        NavigationView {
            ZStack {
                HStack(spacing: 0) {
                    // 侧边菜单
                    SideMenu(showMenu: $viewModel.showMenu)
                    VStack(spacing: 0) {
                        // 标签页内容
                        tabViewContent
                            .navigationBarHidden(true)
                    }
                    .frame(width: getRect().width)
                    .overlay(menuOverlay)  // 添加菜单遮罩层
                }
                .frame(width: getRect().width + viewModel.sideBarWidth)
                .offset(x: -viewModel.sideBarWidth / 2)
                .offset(x: viewModel.offset > 0 ? viewModel.offset : 0)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .animation(.easeOut, value: viewModel.offset == 0)
            .onChange(of: viewModel.showMenu) {
                updateMenuState()  // 更新菜单状态
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }

    /// iPad设备的分屏布局视图
    private var iPadLayoutView: some View {
        NavigationSplitView {
            // 侧边栏内容
            SideMenu(showMenu: $viewModel.showMenu)
                .frame(minWidth: 320, idealWidth: viewModel.sideBarWidth, maxWidth: 400)
                .background(Color.white)
        } detail: {
            // 主要内容区域
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

    /// 菜单遮罩层视图
    private var menuOverlay: some View {
        Rectangle()
            .fill(Color.primary.opacity(Double(viewModel.offset / viewModel.sideBarWidth / 5)))
            .ignoresSafeArea(.container, edges: .vertical)
            .onTapGesture { viewModel.closeMenu() }  // 点击遮罩关闭菜单
    }
    
    /// 更新菜单状态
    private func updateMenuState() {
        guard viewModel.isHomeTab else { return }
        
        // 打开菜单时的状态更新
        if viewModel.showMenu && viewModel.offset == 0 {
            viewModel.offset = viewModel.sideBarWidth
            viewModel.lastStoredOffset = viewModel.offset
        }
        
        // 关闭菜单时的状态更新
        if !viewModel.showMenu && viewModel.offset == viewModel.sideBarWidth {
            viewModel.offset = 0
            viewModel.lastStoredOffset = 0
        }
    }
    
    // MARK: - 标签页内容
    /// 标签页视图内容
    private var tabViewContent: some View {
        VStack {
            TabView(selection: $navigationManager.selectedTab) {
                // 主页标签
                homeTab
                    .tabItem { Image(systemName: "house.fill") }
                    .tag(TabRoute.home)
                
                // 附近标签
                NearbyView()
                    .tabItem { Image(systemName: "location.fill") }
                    .tag(TabRoute.nearby)
                
                // 发布标签
                plusTab
                    .tabItem { Image(systemName: "plus.circle.fill") }
                    .tag(TabRoute.post)
                
                // 聊天标签
                ChatRoomListView()
                    .tabItem { Image(systemName: "message.fill") }
                    .tag(TabRoute.chat)
                
                // 个人资料标签
                ProfileView()
                    .tabItem { Image(systemName: "person.fill") }
                    .tag(TabRoute.profile)
            }
            .accentColor(.black)
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    /// 主页标签内容
    private var homeTab: some View {
        NavigationStack(path: $navigationManager.navigationPath) {
            VStack(spacing: 0) {
                // 搜索和筛选视图
                SearchAndFilterView(search: $viewModel.search)
                    .padding(.bottom, 10)
                // 滚动内容视图
                TabStateScrollView(
                    axis: .vertical,
                    showsIndicator: false,
                    tabState: $viewModel.tabState,
                    isNavigationBarHidden: $viewModel.isNavigationBarHidden
                ) {
                    HomeTabContentView()
                        .navigationBarHidden(viewModel.isNavigationBarHidden)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                leadingNavBarItem  // 左侧导航栏按钮
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                trailingNavBarItem // 右侧导航栏按钮
                            }
                        }
                }
            }
            // 导航目标配置
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .chatDetail(let chatRoom):
                    ChatDetailView(chatRoom: chatRoom)
                case .postDetail(let post):
                    PostDetailView(post: post)
                case .settings:
                    PersonSettingsView()
                case .profileEditor:
                    ProfileEditorView()
                default:
                    EmptyView()
                }
            }
            // 模态页面配置
            .sheet(isPresented: $navigationManager.isPresentingSheet) {
                if let route = navigationManager.presentedSheet {
                    sheetView(for: route)
                }
            }
        }
        .toolbar(
            (viewModel.tabState == .hidden || tabBarManager.isViewTabBarHidden || tabBarManager.isNavigatingInTab) ? .hidden : .visible,
            for: .tabBar
        )
        .animation(.easeInOut(duration: 0.2), value: viewModel.tabState == .hidden)
    }
    
    /// 根据路由创建模态视图
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
    
    /// 发布标签内容
    private var plusTab: some View {
        Text("")
            .tabItem { Image(systemName: "plus.circle.fill") }
            .tag(2)
            .onAppear { viewModel.isShowingPostInputView = true }
            .fullScreenCover(isPresented: $viewModel.isShowingPostInputView) {
                PostInputView(
                    isPresented: $viewModel.isShowingPostInputView,
                    selectedTab: $navigationManager.selectedTab
                )
            }
    }
    
    /// 左侧导航栏按钮
    private var leadingNavBarItem: some View {
        Button(action: viewModel.toggleMenu) {
            Image(uiImage: #imageLiteral(resourceName: "menu"))
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.black)
        }
    }
    
    /// 右侧导航栏按钮（显示位置信息）
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

// MARK: - 视图扩展
/// 添加一个隐藏标签栏的便利修饰符
extension View {
    func hideTabBarOnAppear(_ tabBarManager: TabBarManager) -> some View {
        self
            .onAppear {
                tabBarManager.isNavigatingInTab = true
            }
            .onDisappear {
                tabBarManager.isNavigatingInTab = false
            }
    }
}

// MARK: - 预览
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(TabBarManager())
            .environmentObject(AuthManager())
            .environmentObject(AppNavigationManager.shared)
            .environmentObject(LocationManager.shared)
    }
}

// MARK: - 辅助函数
/// 获取屏幕尺寸
func getRect() -> CGRect {
    return UIScreen.main.bounds
}
