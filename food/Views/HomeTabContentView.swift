import SwiftUI

struct HomeTabContentView: View {
    @Binding var isTabBarHidden: Bool
    
    @State private var tabState: Visibility = .visible
   
    
    @State private var search: String = ""
    @State private var recommendedRecipes = [
        RecommendedRecipe(
           imageName: "sample1",
            title: "有一起打球的的吗",
            imageNames: ["sample1", "reco_2", "reco_3"]
        ),
        RecommendedRecipe(
            imageName: "reco_2",
            title: "永驻申请进度讨论群",
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
            //TabStateScrollView(axis: .vertical, showsIndicator: false, tabState: $tabState)
            ScrollView(showsIndicators: false){
                VStack(alignment: .leading, spacing: 4) {
                    SearchAndFilterView(search: $search)
//                    SectionTitleView(title: "根据位置进行过滤")
//                    FreshRecipesView()
                    // 推荐内容
                    VStack(spacing: 10) {
                        ForEach(recommendedRecipes) { recipe in
                            NavigationLink(
                                destination: RecipeDetailView(recipe: recipe)
                                 
                                    .onAppear {
                                                                           // 隐藏 TabBar
                                                                           isTabBarHidden = true
                                                                       }
                                    .onDisappear {
                                                                            // 显示 TabBar
                                                                            isTabBarHidden = false
                                                                        }
                            ) {
                                RecommendedRecipeCardView(
                                    image: UIImage(named: recipe.imageName) ?? UIImage(),
                                    title: recipe.title,
                                    onTap: {},
                                    busynessLevel: Color.red
                                )
                                .frame(maxWidth: 350)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            
        }
    }
}

struct HomeTabContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabContentView(isTabBarHidden: .constant(false))
    }
}
