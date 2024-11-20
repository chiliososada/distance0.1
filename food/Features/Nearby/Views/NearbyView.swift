import SwiftUI
import MapKit

struct NearbyView: View {
    @StateObject private var viewModel = NearbyViewModel()
    @EnvironmentObject private var navigationManager: AppNavigationManager
    var body: some View {
        ZStack {
            ClusterMapView(
                dataManager: viewModel.mapDataManager,
                viewModel: viewModel
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    VStack {
                        SearchBarView(search: $viewModel.search, showFilterView: $viewModel.showFilterView)
                        ActionButtonsView(viewModel: viewModel)
                    }
                    .padding(.top, getSafeAreaTop())
                    Spacer()
                }
                Spacer()
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
    
    private func getSafeAreaTop() -> CGFloat {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = scene?.windows.first
        return window?.safeAreaInsets.top ?? 47
    }
}

struct BottomMenuView: View {
    let selectedPosts: [LocationPost]
    @EnvironmentObject private var navigationManager: AppNavigationManager
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
                                dismiss()
                                navigationManager.navigate(to: .postDetail(post: post))
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

#Preview {
    NearbyView()
        .environmentObject(AppNavigationManager.shared)
}
