
import SwiftUI


// MARK: - HomeTabContentView
struct HomeTabContentView: View {
    @StateObject private var viewModel = HomeTabContentViewModel()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject private var navigationManager: AppNavigationManager
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16, pinnedViews: []) {
                ForEach(viewModel.recommendedRecipes) { recipe in
                    RecipeCardButton(recipe: recipe) {
                        navigationManager.navigate(to: .recipeDetail(recipe: recipe))
                    }
                }
            }
            .padding()
        }
        .scrollDismissesKeyboard(.immediately)
    }
}

struct RecipeCardButton: View {
    let recipe: RecommendedRecipe
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RecipeCard(recipe: recipe)
                .id(recipe.id)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
// MARK: - Author Header
struct AuthorHeader: View {
    let recipe: RecommendedRecipe
    
    var body: some View {
        HStack(alignment: .center) {
            // 左侧头像和信息
            HStack(spacing: 8) {
                // 头像
                Image(recipe.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                
                // 作者信息
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.authorName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        Image(systemName: "location.circle.fill")
                            .foregroundColor(.gray)
                        Text(recipe.location)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
            }
            
            // 右对齐收藏按钮
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "heart")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
        }
    }
}


struct TagsRow: View {
    let tags: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

// MARK: - Card Footer
struct CardFooter: View {
    let recipe: RecommendedRecipe
    
    var body: some View {
        HStack(alignment: .center) {
            // 左侧信息组
            HStack(spacing: 12) {
                // 人数信息
                HStack(spacing: 4) {
                    Image(systemName: "person.2")
                        .foregroundColor(.gray)
                    Text("\(recipe.participantsCount)人")
                }
                
                // 时间信息
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                    Text(recipe.postedTime)
                }
            }
            .font(.caption)
            .foregroundColor(.gray)
            
            // 右对齐距离信息
            Spacer()
            
            Text("距离我 \(recipe.distance)m")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}


// MARK: - Modified ViewModel for Preview
extension HomeTabContentViewModel {
    static var preview: HomeTabContentViewModel {
        let viewModel = HomeTabContentViewModel()
        viewModel.recommendedRecipes = RecommendedRecipe.sampleData
        return viewModel
    }
}

// MARK: - Modified HomeTabContentView for Preview
struct HomeTabContentView_WithPreviewData: View {
    @StateObject private var viewModel = HomeTabContentViewModel.preview
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.recommendedRecipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe) .environmentObject(AppNavigationManager.shared)) {
                        RecipeCard(recipe: recipe)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Previews
struct HomeTabContentView_Previews: PreviewProvider {
    static var previews: some View {
   
            // 亮色模式预览
            NavigationView {
                HomeTabContentView_WithPreviewData()
                    .environmentObject(TabBarManager())
                    .environment(\.colorScheme, .light)
            }
            .previewDisplayName("Light Mode")
            
           
        
    }
}
