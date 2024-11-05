import SwiftUI
import CoreLocation




// MARK: - HomeView
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var tabBarManager: TabBarManager
    @EnvironmentObject private var navigationManager: AppNavigationManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
         Group {
             if horizontalSizeClass == .compact {
                 mainNavigationView
             } else {
                 iPadLayoutView
             }
         }
     }
    private var mainNavigationView: some View {
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
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .animation(.easeOut, value: viewModel.offset == 0)
            .onChange(of: viewModel.showMenu) {
                updateMenuState()
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
    private var iPadLayoutView: some View {
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

    private var menuOverlay: some View {
        Rectangle()
            .fill(Color.primary.opacity(Double(viewModel.offset / viewModel.sideBarWidth / 5)))
            .ignoresSafeArea(.container, edges: .vertical)
            .onTapGesture { viewModel.closeMenu() }
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
              TabView(selection: $navigationManager.selectedTab) {
                  homeTab
                      .tabItem { Image(systemName: "house.fill") }
                      .tag(TabRoute.home)
                  
                  NearbyView()
                      .tabItem { Image(systemName: "location.fill") }
                      .tag(TabRoute.nearby)
                  
                  plusTab
                      .tabItem { Image(systemName: "plus.circle.fill") }
                      .tag(TabRoute.post)
                  
                  ChatRoomListView()
                      .tabItem { Image(systemName: "message.fill") }
                      .tag(TabRoute.chat)
                  
                  ProfileView()
                      .tabItem { Image(systemName: "person.fill") }
                      .tag(TabRoute.profile)
              }
              .accentColor(.black)
              .edgesIgnoringSafeArea(.bottom)
              .toolbar(
                              (!tabBarManager.isNavigatingInTab && !tabBarManager.isViewTabBarHidden) ? .visible : .hidden,
                              for: .tabBar
                          )
          }
      }
    
    private var homeTab: some View {
         NavigationStack(path: $navigationManager.navigationPath) {
             VStack(spacing: 0) {
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
             }
             .navigationDestination(for: AppRoute.self) { route in
                             switch route {
                             case .chatDetail(let chatRoom):
                                 ChatDetailView(chatRoom: chatRoom)
                                 
                             case .recipeDetail(let recipe):
                                 RecipeDetailView(recipe: recipe)
                                   
                             case .settings:
                                 PersonSettingsView()
                                   
                             case .profileEditor:
                                 ProfileEditorView()
                             default:
                                 EmptyView()
                             }
                         }
             .sheet(isPresented: $navigationManager.isPresentingSheet) {
                 if let route = navigationManager.presentedSheet {
                     sheetView(for: route)
                 }
             }
         }
         .toolbar(
             (viewModel.tabState == .hidden || tabBarManager.isViewTabBarHidden) ? .hidden : .visible,
             for: .tabBar
         )
         .animation(.easeInOut(duration: 0.2), value: viewModel.tabState == .hidden)
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
// Extension 添加一个便利修饰符
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
// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(TabBarManager())
            .environmentObject(AppNavigationManager.shared)
    }
}

// MARK: - Helper
func getRect() -> CGRect {
    return UIScreen.main.bounds
}
