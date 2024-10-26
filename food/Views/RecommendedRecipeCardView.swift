//import SwiftUI
//
//// MARK: - Main Card View
//struct RecommendedRecipeCardView: View {
//    let image: UIImage
//    let title: String
//    let onTap: () -> Void
//    let busynessLevel: Color
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            // 个人资料和标题部分
//            ProfileHeader(image: image)
//            
//            // 标题
//            Text(title)
//                .font(.headline)
//                .fontWeight(.semibold)
//                .foregroundColor(.primary)
//            
//            // 图片画廊
//            ImageGallery(images: ["fresh_recipe_2", "fresh_recipe_2", "fresh_recipe_2"])
//            
//            // 标签
//            TagsView(tags: ["#中古", "#兼职", "#手机"])
//            
//            // 页脚信息
//            FooterInfo()
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(16)
//        .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: 2)
//    }
//}
//
//// MARK: - Profile Header
//private struct ProfileHeader: View {
//    let image: UIImage
//    
//    var body: some View {
//        HStack(alignment: .top, spacing: 12) {
//            // 头像
//            Image(uiImage: image)
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(width: 50, height: 50)
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
//            
//            VStack(alignment: .leading, spacing: 4) {
//                Text("liu ziyuan")
//                    .font(.subheadline)
//                    .fontWeight(.medium)
//                
//                LocationView()
//            }
//            
//            Spacer()
//            
//            LikeButton()
//        }
//    }
//}
//
//// MARK: - Supporting Views
//private struct LocationView: View {
//    var body: some View {
//        HStack(spacing: 4) {
//            Image(systemName: "location.circle.fill")
//                .resizable()
//                .frame(width: 12, height: 12)
//                .foregroundColor(.gray)
//            
//            Text("東京都 葛飾区 立石")
//                .font(.caption2)
//                .foregroundColor(.gray)
//                .lineLimit(1)
//        }
//    }
//}
//
//private struct LikeButton: View {
//    @State private var isLiked = false
//    
//    var body: some View {
//        Button(action: { isLiked.toggle() }) {
//            Image(systemName: isLiked ? "heart.fill" : "heart")
//                .resizable()
//                .frame(width: 24, height: 22)
//                .foregroundColor(isLiked ? .red : .gray)
//        }
//        .animation(.easeInOut, value: isLiked)
//    }
//}
//
//private struct ImageGallery: View {
//    let images: [String]
//    
//    var body: some View {
//        LazyHStack(spacing: 8) {
//            ForEach(images.prefix(4), id: \.self) { imageName in
//                ImageTile(imageName: imageName)
//            }
//            
//            if images.count > 4 {
//                MoreImagesTile(count: images.count - 4)
//            }
//        }
//        .frame(height: 100)
//    }
//}
//
//private struct ImageTile: View {
//    let imageName: String
//    
//    var body: some View {
//        Image(imageName)
//            .resizable()
//            .aspectRatio(contentMode: .fill)
//            .frame(width: 80, height: 80)
//            .clipShape(RoundedRectangle(cornerRadius: 8))
//    }
//}
//
//private struct MoreImagesTile: View {
//    let count: Int
//    
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 8)
//                .fill(Color.black.opacity(0.6))
//                .frame(width: 80, height: 80)
//            
//            Text("+\(count)")
//                .font(.title3)
//                .bold()
//                .foregroundColor(.white)
//        }
//    }
//}
//
//private struct TagsView: View {
//    let tags: [String]
//    
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            LazyHStack(spacing: 8) {
//                ForEach(tags, id: \.self) { tag in
//                    Text(tag)
//                        .font(.caption)
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 6)
//                        .background(Color.blue.opacity(0.1))
//                        .foregroundColor(.blue)
//                        .clipShape(Capsule())
//                }
//            }
//        }
//    }
//}
//
//private struct FooterInfo: View {
//    var body: some View {
//        HStack(spacing: 16) {
//            InfoItem(icon: "person.2", text: "99人")
//            InfoItem(icon: "clock", text: "10 mins")
//            Spacer()
//            Text("距离我 300m")
//                .font(.caption)
//                .foregroundColor(.gray)
//        }
//    }
//}
//
//private struct InfoItem: View {
//    let icon: String
//    let text: String
//    
//    var body: some View {
//        HStack(spacing: 4) {
//            Image(systemName: icon)
//            Text(text)
//        }
//        .font(.caption)
//        .foregroundColor(.gray)
//    }
//}
//
//// MARK: - Preview
//struct RecommendedRecipeCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecommendedRecipeCardView(
//            image: UIImage(named: "fresh_recipe_1") ?? UIImage(),
//            title: "French Toast with Berries",
//            onTap: {},
//            busynessLevel: .red
//        )
//        .previewLayout(.sizeThatFits)
//        .padding()
//    }
//}
