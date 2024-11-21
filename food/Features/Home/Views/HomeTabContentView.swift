
import SwiftUI


// MARK: - HomeTabContentView
struct HomeTabContentView: View {
    
    init() {
      
        print("HomeTabContentView")
       
    }
    
    
    @StateObject private var viewModel = HomeTabContentViewModel()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject private var navigationManager: AppNavigationManager
    private let contentId = "HomeTabContent"
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16, pinnedViews: []) {
                ForEach(viewModel.posts) { post in
                    LocationPostButton(post: post) {
                        navigationManager.navigate(to: .postDetail(post: post))
                    }
                    .id(post.id) // 为每个帖子添加唯一ID
                }
            }
            .padding()
        }
        .id(contentId)
        .scrollDismissesKeyboard(.immediately)
    }
}

struct LocationPostButton: View {
    let post: LocationPost
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            LocationPostCard(post: post, action: action)
                       .id(post.id)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
// MARK: - Author Header
struct AuthorHeader: View {
    let post: LocationPost
    
    var body: some View {
        HStack(alignment: .center) {
            // 左侧头像和信息
            HStack(spacing: 8) {
                // 头像
                Image(post.avatarImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                
                // 作者信息
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.authorName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        Image(systemName: "location.circle.fill")
                            .foregroundColor(.gray)
                        Text(post.locationName)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
            }
            
            // 右对齐收藏按钮
            Spacer()
            
            Button(action: {}) {
                Image(systemName: post.isLiked ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundColor(post.isLiked ? .red : .gray)
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
    let post: LocationPost
    
    var body: some View {
        HStack(alignment: .center) {
            // 左侧信息组
            HStack(spacing: 12) {
                // 人数信息
                HStack(spacing: 4) {
                    Image(systemName: "person.2")
                        .foregroundColor(.gray)
                    Text("\(post.participantsCount)人")
                }
                
                // 时间信息
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                    Text(post.postedTime)
                }
            }
            .font(.caption)
            .foregroundColor(.gray)
            
            Spacer()
            
            // 距离信息，使用格式化的距离显示
            Text(post.formattedDistance)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}



