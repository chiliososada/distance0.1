import SwiftUI

struct HomeTabContentView: View {
   
    
    @State private var tabState: Visibility = .visible
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State private var search: String = ""
    @State private var recommendedRecipes = [
        RecommendedRecipe(
           imageName: "sample1",
            title: "有一起打球的的吗",
            imageNames: ["sample1", "reco_2", "reco_3","reco_3","reco_3","reco_3"]
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                // 推荐内容
                LazyVStack(spacing: 10) {
                    ForEach(recommendedRecipes) { recipe in
                        NavigationLink(
                            destination: RecipeDetailView(recipe: recipe)
                        ) {
                            RecommendedRecipeCardView(
                                image: UIImage(named: recipe.imageName) ?? UIImage(),
                                title: recipe.title,
                                onTap: {},
                                busynessLevel: Color.red
                            )
                            .frame(maxWidth: horizontalSizeClass == .compact ? 350 : .infinity)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

struct HomeTabContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabContentView()
    }
}
