import SwiftUI
import MapKit

struct NearbyView: View {
    @StateObject private var viewModel = NearbyViewModel()
    @EnvironmentObject private var navigationManager: AppNavigationManager
    @EnvironmentObject private var tabBarManager: TabBarManager  // 添加 TabBarManager
    var body: some View {
        NavigationStack(path: $navigationManager.navigationPath) {  // 添加 NavigationStack
            ZStack {
                ClusterMapView(
                                   dataManager: viewModel.mapDataManager,
                                   viewModel: viewModel
                               )
                .edgesIgnoringSafeArea([.top, .leading, .trailing])
                
                VStack {
                    HStack {
                        Spacer()
                        VStack {
                            SearchBarView(search: $viewModel.search, showFilterView: $viewModel.showFilterView)
                            ActionButtonsView(viewModel: viewModel)
                        }
                        .padding(.top, 40)
                        Spacer()
                    }
                    Spacer()
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                          switch route {
                          case .postDetail(let post):
                              PostDetailView(post: post)
                                  .environmentObject(navigationManager)
                                  .environmentObject(tabBarManager)
                          case .chatDetail(let chatRoom):
                                           ChatDetailView(chatRoom: chatRoom)
                                               .environmentObject(navigationManager)
                                               .environmentObject(tabBarManager)
                          default:
                              EmptyView()
               }
             }
            .sheet(isPresented: $viewModel.showBottomSheet) {
                BottomMenuView(selectedPosts: viewModel.selectedPosts)
                    .environmentObject(navigationManager)
                    .presentationDetents([.fraction(0.5), .large])
            }
            .sheet(isPresented: $viewModel.showFilterView) {
                SearchFilterView(showFilterView: $viewModel.showFilterView)
            }
        }
        .onAppear {
                   tabBarManager.isNavigatingInTab = false
               }
    }
}

// 预览
struct NearbyView_Previews: PreviewProvider {
    static var previews: some View {
        NearbyView()
            .environmentObject(AppNavigationManager.shared)  // 添加环境对象
            .environmentObject(TabBarManager())  // 添加 TabBarManager
    }
}

struct BottomMenuView: View {
    let selectedPosts: [LocationPost]
    @State private var showSponsored: Bool = true
    @EnvironmentObject private var navigationManager: AppNavigationManager
    @EnvironmentObject private var tabBarManager: TabBarManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Selected Places (\(selectedPosts.count))")
                .font(.headline)
                .padding()
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(selectedPosts) { post in
                        PlaceCardView(
                            post: post,
                            action: {
                                dismiss()  // 先关闭 sheet
                                // 确保在主线程执行导航
                                DispatchQueue.main.async {
                                    tabBarManager.isNavigatingInTab = true
                                    navigationManager.navigate(to: .postDetail(post: post))
                                    
                                }
                               }
                        )
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    }
                }
            }
        }
        .padding()
    }
}


struct PlaceCardView: View {
    let post: LocationPost
    let action: () -> Void
    
    var body: some View {
        LocationPostCard(post: post, action: action)
    }
}
