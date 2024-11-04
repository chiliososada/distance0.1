import SwiftUI
import MapKit

struct NearbyView: View {
    @StateObject private var viewModel = NearbyViewModel()
    
    var body: some View {
        ZStack {
            ClusterMapView(
                showBottomSheet: $viewModel.showBottomSheet,
                selectedPlaceNames: $viewModel.selectedPlaceNames
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
        .background(Color.clear)
        .sheet(isPresented: $viewModel.showBottomSheet) {
            BottomMenuView(placeNames: viewModel.selectedPlaceNames)
                .presentationDetents([.fraction(0.5), .large])
        }
        .sheet(isPresented: $viewModel.showFilterView) {
            SearchFilterView(showFilterView: $viewModel.showFilterView)
        }
    }
}

// 预览
struct NearbyView_Previews: PreviewProvider {
    static var previews: some View {
        NearbyView()
    }
}


struct BottomMenuView: View {
    let placeNames: [String]
    @State private var showSponsored: Bool = true
    
    var body: some View {
        VStack {
            Text("Selected Places (\(placeNames.count))")
                .font(.headline)
                .padding()
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(Array(placeNames.enumerated()), id: \.element) { index, name in
                        PlaceCardView(placeName: name)
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
    let placeName: String
    
    var body: some View {
        RecipeCard(
            recipe: RecommendedRecipe(
                imageName: "fresh_recipe_1",
                title: placeName,
                imageNames: ["fresh_recipe_1", "fresh_recipe_1"],
                authorName: "Place Owner",
                location: "Location",
                tags: ["Tag1", "Tag2"],
                participantsCount: 0,
                postedTime: "Just now",
                distance: 100,
                isLiked: false,
                avatarImage: "sample2",
                remainingDays: "3 days",
                publishDate: "2024-10-01",
                joinedCount: "75＋",
                content: "今天早上我有个计划，就是去入管局办理一些手续。最近一直忙着工作，所以这件事拖了好久。想着今天正好有空，赶紧去处理一下。"
            )
        )
    }
}
