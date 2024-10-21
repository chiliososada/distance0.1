import SwiftUI
import CoreLocation

struct HomeView: View {
    @State private var selectedTab = 0
    @State private var isShowingPostInputView = false
    @State private var isViewTabBarHidden = false
    @EnvironmentObject var tabBarManager: TabBarManager
    @State private var tabState: Visibility = .visible
    @State var showMenu: Bool = false
    @State var offset: CGFloat = 0
    @State var lastStoredOffset: CGFloat = 0
    @GestureState var gestureOffSet: CGFloat = 0
    @State private var search: String = ""
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State var isNavigationBarHidden: Bool = false
    @State private var isInteracting = false // 用于防止重复点击
    
    @StateObject private var locationManager = LocationManager.shared
    @State  var userLocationText: String = "" // 默认位置文本
  
    init() {
           print("HomeView initialized")
       }
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
                                closeMenuWithDelay()
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
    // 延迟关闭菜单，防止重复点击
    private func closeMenuWithDelay() {
        // 如果已经在处理中，阻止新的点击
        if isInteracting { return }

        // 标记为正在处理中，防止重复点击
        isInteracting = true

        // 动画关闭菜单
        withAnimation {
            showMenu = false
            offset = 0
        }

        // 设置一个延迟，确保短时间内不会再次触发点击操作
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isInteracting = false // 0.5 秒后重置交互状态，允许新的点击
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
                            )   .onAppear {
                                locationManager.startUpdatingLocation() // 开始获取用户位置
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                       updateLocationText()  // 延迟调用以确保位置更新完成
                                   }
                      
                             }
                    }
                    .toolbar((tabState == .hidden || tabBarManager.isViewTabBarHidden) ? .hidden : .visible, for: .tabBar)
                    .animation(.easeInOut(duration: 0.2), value: tabState == .hidden)
                    
                }.onAppear {
                  
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
                // 发布按钮 Tab
                 Text("")
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
            toggleMenuWithDebounce() // 使用防抖动机制控制侧滑菜单
        }) {
            Image(uiImage: #imageLiteral(resourceName: "menu"))
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.black)
        }
    }

    var trailingNavBarItem: some View {
            Button(action: {
          
            }) {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.gray)
                    Text(userLocationText)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
        }


    // 更新用户位置文本
       func updateLocationText() {
           if let location = locationManager.userLocation {
               let geocoder = CLGeocoder()
               geocoder.reverseGeocodeLocation(location) { placemarks, error in
                   if let placemark = placemarks?.first {
                       DispatchQueue.main.async {
                           // 获取都道府县 (例如：东京都)、市区 (例如：葛饰区) 和街道 (例如：立石)
                           let administrativeArea = placemark.administrativeArea ?? "Unknown" // 都道府县
                           let locality = placemark.locality ?? "Unknown" // 市区
                           let subLocality = placemark.subLocality ?? "" // 街道/较小的区划

                           // 拼接完整地址 (例如：东京都 葛饰区 立石)
                           userLocationText = "\(administrativeArea) \(locality) \(subLocality)"
                       }
                   } else {
                       print("Failed to get placemark: \(String(describing: error))")
                   }
               }
           }
       }
    // 防止重复点击的侧滑菜单开关
    private func toggleMenuWithDebounce() {
        if isInteracting { return } // 如果已经在处理中，阻止新的点击
        isInteracting = true
        
        withAnimation {
            showMenu.toggle()
        }
        
        // 设置延迟以避免重复点击
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isInteracting = false // 0.5秒后允许新的点击
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

