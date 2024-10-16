import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0
 //   @Binding var selectedTab: Int // 传递 selectedTab 绑定
    @State private var isShowingPostInputView = false
    @State private var isViewTabBarHidden = false
    @EnvironmentObject var tabBarManager: TabBarManager
    @State private var tabState: Visibility = .visible
    @State var showMenu: Bool = false
    @State var offset: CGFloat = 0
    @State var lastStoredOffset: CGFloat = 0
    @GestureState var gestureOffSet: CGFloat = 0
    @State private var search: String = ""
    @Environment(\.horizontalSizeClass) var horizontalSizeClass  // 检测 iPad 或 iPhone
    @State  var isNavigationBarHidden: Bool = false  // Track navigation bar visibility

    
    var body: some View {
        let sideBarWidth = getRect().width * 0.7
        NavigationView {
            ZStack {
                HStack(spacing: 0) {
                    // Side Menu
                    SideMenu(showMenu: $showMenu)
                    VStack(spacing: 0) {
                        tabViewContent // 放置 TabView 和它的内容
                            .navigationBarHidden(true)
                    }
                    .frame(width: getRect().width) // 确保 TabView 和内容占满屏幕宽度
                    .overlay(
                        // 遮罩层，点击关闭侧边栏
                        Rectangle()
                            .fill(Color.primary.opacity(Double(offset / sideBarWidth / 5)))
                            .ignoresSafeArea(.container, edges: .vertical)
                            .onTapGesture {
                                withAnimation { showMenu.toggle() }
                            }
                    )
                }
                .frame(width: getRect().width + sideBarWidth)
                .offset(x: -sideBarWidth / 2)
                .offset(x: offset > 0 ? offset : 0)
                .gesture(
                    DragGesture()
                        .updating($gestureOffSet, body: { value, out, _ in
                            out = value.translation.width
                        })
                        .onEnded(onEnd(value:))
                )
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .animation(.easeOut, value: offset == 0)
            .onChange(of: showMenu) {
                if showMenu && offset == 0 {
                    offset = sideBarWidth
                    lastStoredOffset = offset
                }
                
                if !showMenu && offset == sideBarWidth {
                    offset = 0
                    lastStoredOffset = 0
                }
            }
            .onChange(of: gestureOffSet) {
                onChange()
            }
            .ignoresSafeArea(edges: .bottom)
            
        }
    }
    var tabViewContent: some View {
        VStack {
            TabView(selection: $selectedTab) {
                // 主页 Tab
                NavigationStack {
                    SearchAndFilterView(search: $search)
                    TabStateScrollView(axis: .vertical, showsIndicator: false, tabState: $tabState, isNavigationBarHidden: $isNavigationBarHidden) {
                        HomeTabContentView()
                            .navigationBarHidden(isNavigationBarHidden) 
                            .navigationBarItems(
                                leading: leadingNavBarItem,
                                trailing: trailingNavBarItem
                            )
                           
                    }
//                 .toolbar(isTabBarHidden || tabState == .hidden ? .hidden : .visible, for: .tabBar)
                    .toolbar((tabState == .hidden || tabBarManager.isViewTabBarHidden) ? .hidden : .visible, for: .tabBar)
                    .animation(.easeInOut(duration: 0.2), value: tabState == .hidden)
                    
                }
                
                .navigationViewStyle(StackNavigationViewStyle())
               
                .tabItem {
                    Image(systemName: "house.fill")
                }
                .tag(0)
                
                // 其他 Tabs
                NearbyView()
                    .tabItem {
                        Image(systemName: "location.fill")
                    }
                    .tag(1)
                // 发布按钮 Tab (This will trigger a sheet)
                 Text("") // Empty content since we're using a sheet
                     .tabItem {
                         Image(systemName: "plus.circle.fill")
                     }
                     .tag(2)
                     .onAppear {
                         isShowingPostInputView = true  // Show the sheet when the tab is selected
                     }
                     .fullScreenCover(isPresented: $isShowingPostInputView) {
                         PostInputView(isPresented: $isShowingPostInputView, selectedTab: $selectedTab)
                     }
                ChatRoomListView()
                    .tabItem {
                        Image(systemName: "message.fill")
                       
                    }
                    .tag(3)

                ProfileView()
                    .tabItem {
                        Image(systemName: "person.fill")
                       
                    }
                    .tag(4)
            }
            .accentColor(.black)
            .edgesIgnoringSafeArea(.bottom)
        
        }
        
    }

    // leading 导航栏按钮，点击时显示侧滑菜单
    var leadingNavBarItem: some View {
        Button(action: {
            withAnimation {
                showMenu.toggle() // 点击按钮切换侧滑菜单状态
            }
        }) {
            Image(uiImage: #imageLiteral(resourceName: "menu"))
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.black)
        }
    }

    var trailingNavBarItem: some View {
        HStack {
            Image(systemName: "mappin.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 12)
                .foregroundColor(.gray)
            Text("東京都 葛飾区 立石")
                .font(.caption2)
                .foregroundColor(.gray)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }

    // 处理侧滑菜单滑动过程中的逻辑
    func onChange() {
        let sideBarWidth = getRect().width - 90

        offset = (gestureOffSet != 0) ? (gestureOffSet + lastStoredOffset < sideBarWidth ? gestureOffSet + lastStoredOffset : offset) : offset
    }

    // 滑动结束时的处理逻辑
    func onEnd(value: DragGesture.Value) {
        let sideBarWidth = getRect().width - 90

        let translation = value.translation.width

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
}

// 获取屏幕尺寸
func getRect() -> CGRect {
    return UIScreen.main.bounds
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView() .environmentObject(TabBarManager()) // Injecting TabBarManager instance
    }
}
 
