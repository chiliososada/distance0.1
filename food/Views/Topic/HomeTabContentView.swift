
import SwiftUI

// MARK: - Models
struct RecommendedRecipe: Identifiable, Hashable {
    let id = UUID()
    let imageName: String          // 保持原有的
    let title: String             // 保持原有的
    let imageNames: [String]      // 保持原有的
    let authorName: String        // 保持原有的
    let location: String          // 保持原有的
    let tags: [String]           // 保持原有的
    let participantsCount: Int    // 保持原有的
    let postedTime: String        // 保持原有的
    let distance: Int            // 保持原有的
    let isLiked: Bool            // 保持原有的
    
    // 新增属性
    let avatarImage: String      // 头像图片名称
    let remainingDays: String    // 剩余时间
    let publishDate: String      // 发布日期
    let joinedCount: String      // 参加人数
    let content: String          // 内容描述
}
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

// MARK: - RecipeCard
struct RecipeCard: View {
    let recipe: RecommendedRecipe
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
   
    private var imageItems: [ImageItem] {
          recipe.imageNames.map { imageName in
              // 获取图片实际尺寸并计算比例
              if let uiImage = UIImage(named: imageName) {
                  let aspectRatio = uiImage.size.width / uiImage.size.height
                  return ImageItem(imageName: imageName, aspectRatio: aspectRatio)
              } else {
                  // 如果无法加载图片，默认使用 1:1 比例
                  return ImageItem(imageName: imageName, aspectRatio: 1.0)
              }
          }
      }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author Header
            AuthorHeader(recipe: recipe)
            
            // Title
            Text(recipe.title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // Image Gallery - 使用原来的 ImageGalleryView
            ImageGalleryView(images: imageItems)
            
            // Tags
            TagsRow(tags: recipe.tags)
            
            // Footer
            CardFooter(recipe: recipe)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .frame(maxWidth: horizontalSizeClass == .compact ? 350 : .infinity)
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
    
    private var cardWidth: CGFloat {
        horizontalSizeClass == .compact ? 350.0 : UIScreen.main.bounds.width - 32
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
        .clipped()
    }
    
    // 单图布局
    private func singleImageView(_ image: ImageItem) -> some View {

        return Image(image.imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: cardWidth, height: cardWidth/image.aspectRatio)
          
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    // 双图布局
    private func twoImagesView(_ images: [ImageItem]) -> some View {
        let spacing: CGFloat = 5
        let itemWidth = (cardWidth - spacing) / 2
        
        return HStack(spacing: spacing) {
            ForEach(0..<2, id: \.self) { index in
                Image(images[index].imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: itemWidth, height: itemWidth)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    private func threeImagesView(_ images: [ImageItem]) -> some View {
        let spacing: CGFloat = 5
        let maxHeight = cardWidth 
        
        // 检查是否有竖图，并且宽高比是 3:4
        let hasPortraitImage = images.contains { image in
            image.isPortrait && abs(image.aspectRatio - 3.0/4.0) < 0.1
        }
        
        // 检查是否有横图，并且宽高比是 4:3
        let hasLandscapeImage = images.contains { image in
            image.isLandscape && abs(image.aspectRatio - 4.0/3.0) < 0.1
        }
        
        return Group {
            if hasPortraitImage {
                // 竖图布局：主图占满整列
                HStack(spacing: spacing) {
                    let mainImageIndex = images.firstIndex { image in
                        image.isPortrait && abs(image.aspectRatio - 3.0/4.0) < 0.1
                    } ?? 0
                    
                    // 主图（竖图）占满左侧
                    Image(images[mainImageIndex].imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit) // 改用 .fill 来确保填充满高度
                        .frame(width: cardWidth * 0.5 - spacing/2)
                        .frame(height: maxHeight)
                        .clipped() // 添加 clipped 来处理超出部分
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // 右侧其他图片
                    let otherIndices = Array(images.indices.filter { $0 != mainImageIndex }.prefix(2))
                    if !otherIndices.isEmpty {
                        VStack(spacing: spacing) {
                            ForEach(otherIndices, id: \.self) { index in
                                Image(images[index].imageName)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(width: cardWidth * 0.5 - spacing/2)
                                    .frame(height: (maxHeight - spacing) / 2)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
                .frame(height: maxHeight)
            } else if hasLandscapeImage {
                // 横图布局：主图占满整行宽度
                VStack(spacing: spacing) {
                    let mainImageIndex = images.firstIndex { image in
                        image.isLandscape && abs(image.aspectRatio - 4.0/3.0) < 0.1
                    } ?? 0
                    
                    // 主图（横图）- 修改这部分以确保占满整行
                    Image(images[mainImageIndex].imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit) // 改用 .fill 来确保填充满宽度
                        .frame(width: cardWidth)
                        .frame(height: maxHeight * 0.6)
                        .clipped() // 添加 clipped 来处理超出部分
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // 下方其他图片
                    let otherIndices = Array(images.indices.filter { $0 != mainImageIndex }.prefix(2))
                    if !otherIndices.isEmpty {
                        HStack(spacing: spacing) {
                            ForEach(otherIndices, id: \.self) { index in
                                Image(images[index].imageName)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(width: (cardWidth - spacing) / 2)
                                    .frame(height: maxHeight * 0.4 - spacing)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
                .frame(height: maxHeight)
            }else {
                // 默认布局：上面两张1:1，下面左侧1:1
                VStack(spacing: spacing) {
                    HStack(spacing: spacing) {
                        ForEach(0..<2) { index in
                            Image(images[index].imageName)
                                .resizable()
                                .aspectRatio(1, contentMode: .fill)
                                .frame(width: (cardWidth - spacing) / 2)
                                .frame(height: (cardWidth - spacing) / 2)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    
                    HStack(spacing: spacing) {
                        Image(images[2].imageName)
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .frame(width: (cardWidth - spacing) / 2)
                            .frame(height: (cardWidth - spacing) / 2)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Spacer()
                    }
                }
                .frame(height: cardWidth + spacing)
            }
        }
    }  
    // 四图及以上布局
    private func fourAndMoreImagesView(_ images: [ImageItem]) -> some View {
        let spacing: CGFloat = 5
        let itemSize = (cardWidth - spacing) / 2
        
        return VStack(spacing: spacing) {
            HStack(spacing: spacing) {
                ForEach(0..<2) { index in
                    Image(images[index].imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: itemSize, height: itemSize)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            
            HStack(spacing: spacing) {
                Image(images[2].imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: itemSize, height: itemSize)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                ZStack {
                    Image(images[3].imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: itemSize, height: itemSize)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    if images.count > 4 {
                        Color.black.opacity(0.4)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        Text("+\(images.count - 4)")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                    }
                }
            }
        }
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

struct ImageGallery: View {
    let images: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(images.prefix(4), id: \.self) { imageName in
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                if images.count > 4 {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.2))
                            .frame(width: 80, height: 80)
                        
                        Text("+\(images.count - 4)")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .frame(height: 80)
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



// MARK: - Custom Navigation Bar
struct CustomNavigationBar: View {
    let leadingButton: () -> AnyView
    let trailingButton: () -> AnyView
    
    init<Leading: View, Trailing: View>(
        leadingButton: @escaping () -> Leading,
        trailingButton: @escaping () -> Trailing
    ) {
        self.leadingButton = { AnyView(leadingButton()) }
        self.trailingButton = { AnyView(trailingButton()) }
    }
    
    var body: some View {
        HStack {
            leadingButton()
            Spacer()
            trailingButton()
        }
        .padding(.horizontal, 16)
        .padding(.top, 45)
    }
}







// MARK: - Preview Helpers
extension RecommendedRecipe {
    static var sampleData: [RecommendedRecipe] = [
        RecommendedRecipe(
            imageName: "sample1",
            title: "有一起打球的的吗",
            imageNames: ["sample1", "reco_2", "reco_3"],
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
            imageNames: ["sample1", "reco_2", "reco_3"],
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
            imageNames: ["sample1", "reco_2", "reco_3"],
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
        )
    ]
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
