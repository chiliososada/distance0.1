
import SwiftUI


// MARK: - HomeTabContentViewModel
final class HomeTabContentViewModel: ObservableObject {
    @Published var recommendedRecipes: [RecommendedRecipe] = []
    
    init() {
        loadInitialData()
    }
    
    private func loadInitialData() {
        // 模拟数据加载
        recommendedRecipes = [
            RecommendedRecipe(
                imageName: "sample1",
                title: "有一起打球的的吗",
                imageNames: ["sample1", "reco_2", "reco_3", "sample1", "reco_3"],
                authorName: "劉子源",
                location: "東京都 葛飾区 立石",
                tags: ["娱乐", "运动", "篮球"],
                participantsCount: 99,
                postedTime: "10 mins",
                distance: 300,
                isLiked: false,
                // 新增属性的值
                avatarImage: "sample2",
                remainingDays: "3 days",
                publishDate: "2024-10-01",
                joinedCount: "75＋",
                content: "今天早上我有个计划，就是去入管局办理一些手续。最近一直忙着工作，所以这件事拖了好久。想着今天正好有空，赶紧去处理一下。"
                
            ),
            RecommendedRecipe(
                imageName: "sample1",
                title: "有一起打球的的吗",
                imageNames: ["4_3"],
                authorName: "劉子源",
                location: "東京都 葛飾区 立石",
                tags: ["娱乐", "运动", "篮球"],
                participantsCount: 99,
                postedTime: "10 mins",
                distance: 300,
                isLiked: false,
                // 新增属性的值
                avatarImage: "sample2",
                remainingDays: "3 days",
                publishDate: "2024-10-01",
                joinedCount: "75＋",
                content: "今天早上我有个计划，就是去入管局办理一些手续。最近一直忙着工作，所以这件事拖了好久。想着今天正好有空，赶紧去处理一下。"
            ),
            
            RecommendedRecipe(
                imageName: "sample1",
                title: "有一起打球的的吗",
                imageNames: ["4_5"],
                authorName: "劉子源",
                location: "東京都 葛飾区 立石",
                tags: ["娱乐", "运动", "篮球"],
                participantsCount: 99,
                postedTime: "10 mins",
                distance: 300,
                isLiked: false,
                // 新增属性的值
                avatarImage: "sample2",
                remainingDays: "3 days",
                publishDate: "2024-10-01",
                joinedCount: "75＋",
                content: "今天早上我有个计划，就是去入管局办理一些手续。最近一直忙着工作，所以这件事拖了好久。想着今天正好有空，赶紧去处理一下。"
            ),
            RecommendedRecipe(
                imageName: "sample1",
                title: "一起去看电影吧",
                imageNames: ["1_1"],
                authorName: "王小明",
                location: "東京都 新宿区",
                tags: ["娱乐", "电影", "社交"],
                participantsCount: 56,
                postedTime: "20 mins",
                distance: 500,
                isLiked: false,
                // 新增属性的值
                avatarImage: "sample2",
                remainingDays: "3 days",
                publishDate: "2024-10-01",
                joinedCount: "75＋",
                content: "今天早上我有个计划，就是去入管局办理一些手续。最近一直忙着工作，所以这件事拖了好久。想着今天正好有空，赶紧去处理一下。"
            ),
            RecommendedRecipe(
                imageName: "sample1",
                title: "有一起打球的的吗",
                imageNames: ["4_3","4_5"],
                authorName: "劉子源",
                location: "東京都 葛飾区 立石",
                tags: ["娱乐", "运动", "篮球"],
                participantsCount: 99,
                postedTime: "10 mins",
                distance: 300,
                isLiked: false,
                // 新增属性的值
                avatarImage: "sample2",
                remainingDays: "3 days",
                publishDate: "2024-10-01",
                joinedCount: "75＋",
                content: "今天早上我有个计划，就是去入管局办理一些手续。最近一直忙着工作，所以这件事拖了好久。想着今天正好有空，赶紧去处理一下。"
            ),
            RecommendedRecipe(
                imageName: "sample1",
                title: "4_3有一起打球的的吗",
                imageNames: ["4_3","4_5","1_1"],
                authorName: "劉子源",
                location: "東京都 葛飾区 立石",
                tags: ["娱乐", "运动", "篮球"],
                participantsCount: 99,
                postedTime: "10 mins",
                distance: 300,
                isLiked: false,
                // 新增属性的值
                avatarImage: "sample2",
                remainingDays: "3 days",
                publishDate: "2024-10-01",
                joinedCount: "75＋",
                content: "今天早上我有个计划，就是去入管局办理一些手续。最近一直忙着工作，所以这件事拖了好久。想着今天正好有空，赶紧去处理一下。"
            ),
            RecommendedRecipe(
                imageName: "sample1",
                title: "4-3有一起打球的的1吗",
                imageNames: ["4_3","4_3","4_3"],
                authorName: "劉子源",
                location: "東京都 葛飾区 立石",
                tags: ["娱乐", "运动", "篮球"],
                participantsCount: 99,
                postedTime: "10 mins",
                distance: 300,
                isLiked: false,
                // 新增属性的值
                avatarImage: "sample2",
                remainingDays: "3 days",
                publishDate: "2024-10-01",
                joinedCount: "75＋",
                content: "今天早上我有个计划，就是去入管局办理一些手续。最近一直忙着工作，所以这件事拖了好久。想着今天正好有空，赶紧去处理一下。"
            ),
            RecommendedRecipe(
                imageName: "sample1",
                title: "4-5有一起打球的的吗",
                imageNames: ["4_5","4_5","1_1","4_5"],
                authorName: "劉子源",
                location: "東京都 葛飾区 立石",
                tags: ["娱乐", "运动", "篮球"],
                participantsCount: 99,
                postedTime: "10 mins",
                distance: 300,
                isLiked: false,
                // 新增属性的值
                avatarImage: "sample2",
                remainingDays: "3 days",
                publishDate: "2024-10-01",
                joinedCount: "75＋",
                content: "今天早上我有个计划，就是去入管局办理一些手续。最近一直忙着工作，所以这件事拖了好久。想着今天正好有空，赶紧去处理一下。"
            ),
            RecommendedRecipe(
                imageName: "sample1",
                title: "有一起打球的的吗",
                imageNames: ["4_5","4_3"],
                authorName: "劉子源",
                location: "東京都 葛飾区 立石",
                tags: ["娱乐", "运动", "篮球"],
                participantsCount: 99,
                postedTime: "10 mins",
                distance: 300,
                isLiked: false,
                // 新增属性的值
                avatarImage: "sample2",
                remainingDays: "3 days",
                publishDate: "2024-10-01",
                joinedCount: "75＋",
                content: "今天早上我有个计划，就是去入管局办理一些手续。最近一直忙着工作，所以这件事拖了好久。想着今天正好有空，赶紧去处理一下。"
            ),
            RecommendedRecipe(
                imageName: "sample1",
                title: "一起去看电影吧",
                imageNames: ["1_1","1_1","1_1"],
                authorName: "王小明",
                location: "東京都 新宿区",
                tags: ["娱乐", "电影", "社交"],
                participantsCount: 56,
                postedTime: "20 mins",
                distance: 500,
                isLiked: false,
                // 新增属性的值
                avatarImage: "sample2",
                remainingDays: "3 days",
                publishDate: "2024-10-01",
                joinedCount: "75＋",
                content: "今天早上我有个计划，就是去入管局办理一些手续。最近一直忙着工作，所以这件事拖了好久。想着今天正好有空，赶紧去处理一下。"
            ),
            RecommendedRecipe(
                imageName: "sample1",
                title: "音乐节拼车",
                imageNames: ["sample1", "sample1", "sample1", "sample1"],
                authorName: "李华",
                location: "東京都 渋谷区",
                tags: ["音乐", "节日", "拼车"],
                participantsCount: 150,
                postedTime: "30 mins",
                distance: 700,
                isLiked: false,
                // 新增属性的值
                avatarImage: "sample2",
                remainingDays: "3 days",
                publishDate: "2024-10-01",
                joinedCount: "75＋",
                content: "今天早上我有个计划，就是去入管局办理一些手续。最近一直忙着工作，所以这件事拖了好久。想着今天正好有空，赶紧去处理一下。"
            ),
            RecommendedRecipe(
                imageName: "sample1",
                title: "周末一起骑行",
                imageNames: ["reco_3", "sample1"],
                authorName: "张三",
                location: "東京都 世田谷区",
                tags: ["运动", "骑行", "健身"],
                participantsCount: 25,
                postedTime: "1 hour",
                distance: 1000,
                isLiked: false,
                // 新增属性的值
                avatarImage: "sample2",
                remainingDays: "3 days",
                publishDate: "2024-10-01",
                joinedCount: "75＋",
                content: "今天早上我有个计划，就是去入管局办理一些手续。最近一直忙着工作，所以这件事拖了好久。想着今天正好有空，赶紧去处理一下。"
            )
        ]
    }
}

// MARK: - HomeTabContentView
struct HomeTabContentView: View {
    @StateObject private var viewModel = HomeTabContentViewModel()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16, pinnedViews: []) {
                ForEach(viewModel.recommendedRecipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        RecipeCard(recipe: recipe)
                            .id(recipe.id)
                    }
                  
                }
            }
            .padding()
        }
        .scrollDismissesKeyboard(.immediately) // 添加这个来优化键盘处理
    }
}


struct ImageItem {
    let imageName: String
    let aspectRatio: CGFloat // 宽高比 (width/height)
    
    var isPortrait: Bool { aspectRatio < 1 }
    var isLandscape: Bool { aspectRatio > 1 }
    var isSquare: Bool { abs(aspectRatio - 1.0) < 0.1 } // 允许有小误差
}

struct ImageGalleryView: View {
    let images: [ImageItem]
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    private let spacing: CGFloat = 5
    private let cornerRadius: CGFloat = 8
    private let maxHeightRatio: CGFloat = 0.75 // 最大高度比例
    
    private var cardWidth: CGFloat {
        horizontalSizeClass == .compact ? 350.0 : UIScreen.main.bounds.width - 32
    }
    
    // 基础图片修饰符 - 改用 .fit 来确保完整显示
    private func baseImageModifier(_ image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
    
    // 计算图片适合的尺寸
    private func calculateImageSize(_ image: ImageItem, maxWidth: CGFloat) -> CGSize {
        let aspectRatio = max(image.aspectRatio, 0.1)
        let naturalHeight = maxWidth / aspectRatio
        let maxHeight = cardWidth * maxHeightRatio
        let height = min(naturalHeight, maxHeight)
        return CGSize(width: maxWidth, height: height)
    }
    
    private func singleImageView(_ image: ImageItem) -> some View {
        let screenWidth = UIScreen.main.bounds.width
        let aspectRatio = image.aspectRatio
        let height = screenWidth / aspectRatio // 根据宽度和图片比例计算实际需要的高度
        
        return baseImageModifier(Image(image.imageName))
            .frame(width: screenWidth, height: height) // 使用计算出的高度
    }
    // 双图布局
    private func twoImagesView(_ images: [ImageItem]) -> some View {
        let itemWidth = (cardWidth - spacing) / 2
        return HStack(spacing: spacing) {
            ForEach(0..<2, id: \.self) { index in
                let image = images[index]
                let size = calculateImageSize(image, maxWidth: itemWidth)
                baseImageModifier(Image(image.imageName))
                    .frame(width: size.width, height: size.height)
            }
        }
    }
    
    // 三图布局
    private func threeImagesView(_ images: [ImageItem]) -> some View {
        let itemWidth = (cardWidth - spacing) / 2
        return VStack(spacing: spacing) {
            // 第一行一张图
            let firstImageSize = calculateImageSize(images[0], maxWidth: cardWidth)
            baseImageModifier(Image(images[0].imageName))
                .frame(width: firstImageSize.width, height: firstImageSize.height)
            
            // 第二行两张图
            HStack(spacing: spacing) {
                ForEach(1...2, id: \.self) { index in
                    let size = calculateImageSize(images[index], maxWidth: itemWidth)
                    baseImageModifier(Image(images[index].imageName))
                        .frame(width: size.width, height: size.height)
                }
            }
        }
    }
    
    // 四图及以上布局
    private func fourAndMoreImagesView(_ images: [ImageItem]) -> some View {
        let spacing: CGFloat = 5
        let itemWidth = (cardWidth - spacing) / 2
        
        return VStack(spacing: spacing) {
            // 第一行两张图
            HStack(spacing: spacing) {
                ForEach(0..<2, id: \.self) { index in
                    let size = calculateImageSize(images[index], maxWidth: itemWidth)
                    baseImageModifier(Image(images[index].imageName))
                        .frame(width: size.width, height: size.height)
                }
            }
            
            // 第二行两张图，最后一张可能显示剩余数量
            HStack(spacing: spacing) {
                let size3 = calculateImageSize(images[2], maxWidth: itemWidth)
                baseImageModifier(Image(images[2].imageName))
                    .frame(width: size3.width, height: size3.height)
                
                ZStack {
                    let size4 = calculateImageSize(images[3], maxWidth: itemWidth)
                    baseImageModifier(Image(images[3].imageName))
                        .frame(width: size4.width, height: size4.height)
                    
                    if images.count > 4 {
                        Rectangle()
                            .fill(Color.black.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        
                        Text("+\(images.count - 4)")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    var body: some View {
        Group {
            switch images.count {
            case 1:
                singleImageView(images[0])   
            case 2:
                twoImagesView(images)
            case 3:
                threeImagesView(images)
            default:
                fourAndMoreImagesView(images)
            }
        }
        .frame(width: cardWidth)
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
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
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
