import SwiftUI

struct HomeTabContentView: View {
   
    
    @State private var tabState: Visibility = .visible
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State private var search: String = ""
    @State private var recommendedRecipes = [
        RecommendedRecipe(
           imageName: "sample1",
            title: "有一起打球的的吗",
            imageNames: ["sample1", "reco_2", "reco_3"]
        ),
        RecommendedRecipe(
            imageName: "reco_2",
            title: "永驻申请进度讨论群永驻申请进度讨论群永驻申请进度讨论群永驻申请进度讨论群永进度讨论群",
            imageNames: ["reco_2", "reco_3"]
        ),
        RecommendedRecipe(
            imageName: "reco_3",
            title: "中国人找对象",
            imageNames: ["reco_3", "reco_1"]
        ),
        RecommendedRecipe(
            imageName: "reco_3",
            title: "中国人找对象",
            imageNames: ["reco_3", "reco_1"]
        ),
        RecommendedRecipe(
            imageName: "reco_3",
            title: "中国人找对象",
            imageNames: ["reco_3", "reco_1"]
        ),
        RecommendedRecipe(
            imageName: "reco_3",
            title: "中国人找对象",
            imageNames: ["reco_3", "reco_1"]
        ),
        RecommendedRecipe(
            imageName: "reco_3",
            title: "中国人找对象",
            imageNames: ["reco_3", "reco_1"]
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                // 推荐内容
                VStack(spacing: 10) {
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
                            .frame(maxWidth: horizontalSizeClass == .compact ? 350 : .infinity)  // Limit width on iPhone, full width on iPad
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
