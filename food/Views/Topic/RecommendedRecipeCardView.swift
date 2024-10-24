import SwiftUI

// 主卡片视图
struct RecommendedRecipeCardView: View {
    let image: UIImage
    let title: String
    let onTap: () -> Void
    let busynessLevel: Color // 用于表示繁忙程度的颜色
    
    var body: some View {
       
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 10) {
                    // 个人资料和标题部分
                    ProfileImageView(image: image)
                    
                    // 标题
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    // 图片画廊
                    ImageGalleryView(images: ["fresh_recipe_2", "fresh_recipe_2", "fresh_recipe_2", "fresh_recipe_2", "fresh_recipe_2", "fresh_recipe_2"])
                    
                    // 标签行
                    TagsView(tags: ["#中古", "#兼职", "#手机"])
                    
                    // 页脚信息（人数、时间、距离）
                    FooterInfoView()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.12), radius: 7, x: 0, y: 4)
            }
        }
    
}

// 个人资料视图
struct ProfileImageView: View {
    let image: UIImage
    
    var body: some View {
        HStack(alignment: .top) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("liu ziyuan")
                    .font(.caption)
                    .foregroundColor(.black)
                    .bold()
                
                HStack {
                    Image(systemName: "location.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.gray)
                    
                    Text("東京都 葛飾区 立石")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            Spacer()
            
            Image(systemName: "heart")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(.gray)
        }
    }
}

// 标签视图
struct TagsView: View {
    let tags: [String]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.blue.opacity(0.2)))
            }
        }
    }
}

// 页脚信息视图
struct FooterInfoView: View {
    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.gray)
                
                Text("99人")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.gray)
                
                Text("10 mins")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("距离我 300m")
                .font(.caption)
                .foregroundColor(.black)
        }
    }
}

// 图片画廊视图
struct ImageGalleryView: View {
    let images: [String] // 图片名称数组
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<min(4, images.count), id: \.self) { index in
                ZStack {
                    Image(images[index])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: imageWidth(for: images.count), height: imageHeight(for: images.count))
                        .clipped()
                    
                    // 如果图片超过4张，显示 +N 叠加层
                    if index == 3 && images.count > 4 {
                        Color.black.opacity(0.4)
                        
                        Text("+\(images.count - 4)")
                            .foregroundColor(.white)
                            .font(.title)
                            .bold()
                    }
                }
                .frame(width: imageWidth(for: images.count), height: imageHeight(for: images.count))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .clipped()
    }
    
    // 计算动态宽度
    private func imageWidth(for count: Int) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width - 30 // 总宽度减去填充
        switch count {
        case 1:
            return min(screenWidth, 400)
        case 2:
            return (screenWidth - 5) / 2
        case 3:
            return (screenWidth - 10) / 3
        case 4:
            return (screenWidth - 15) / 4
        default:
            return 80
        }
    }

    // 计算动态高度，确保4:3比例
    private func imageHeight(for count: Int) -> CGFloat {
        switch count {
        case 1:
            return min(imageWidth(for: count) * 0.75, 225)
        default:
            return imageWidth(for: count) * 0.75
        }
    }
}

// 预览
struct RecommendedRecipeCardView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendedRecipeCardView(
            image: UIImage(named: "fresh_recipe_1") ?? UIImage(),
            title: "French Toast with Berries",
            onTap: {},
            busynessLevel: Color.red
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
