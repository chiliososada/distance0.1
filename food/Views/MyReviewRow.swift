import SwiftUI

struct MyReviewRow: View {
    let name: String
    let date: String
    let location: String
    let review: String
    let participants: Int
    let tags: [String]
    let timeElapsed: String
    let distance: String
    let title: String // 添加标题
    let showAvatar: Bool // 控制是否显示头像
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 头像和用户信息
            HStack(alignment: .top) {
                if showAvatar {
                    Image("sample2") // 替换为实际的头像图片
                        .resizable()
                        .frame(width: 50, height: 50) // 更大一些的头像
                        .clipShape(Circle())
                        .shadow(radius: 4) // 增加头像的阴影效果
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                    Text(date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                // 时间信息和更多操作图标
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.gray)
                    Text(timeElapsed)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    // 更多选项图标
                    Menu {
                        Button(action: {
                            // 编辑操作
                        }) {
                            Label("编辑", systemImage: "pencil")
                        }
                        
                        Button(action: {
                            // 删除操作
                        }) {
                            Label("删除", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                    }
                }
            }
            
            // 标题
            Text(title)
                .font(.title3)
                .fontWeight(.semibold) // 使用较轻的粗体
                .foregroundColor(.black)
                .lineLimit(2) // 限制两行，避免过长的标题占据太多空间
            
            // 评论内容，最多显示一行，多余部分用省略号显示
            Text(review)
                .font(.footnote) // 使用比 .body 更小的字体
                .foregroundColor(.black)
                .lineLimit(1) // 限制显示一行
                .truncationMode(.tail) // 当超出一行时，显示省略号
            
            // 评论标签
            HStack {
                ForEach(tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12) // 使用更大的圆角
                }
            }
            
            // 参加人数、位置和距离信息
            HStack {
                // 参加人数
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.gray)
                    Text("\(participants) 人")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // 地理位置信息
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.gray)
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12) // 调整圆角
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5) // 优化阴影效果，增添视觉层次感
        .padding(.horizontal)
    }
}

// 添加预览
struct MyReviewRow_Previews: PreviewProvider {
    static var previews: some View {
        MyReviewRow(
            name: "John Doe",
            date: "2024-10-03",
            location: "東京都 葛飾区 立石",
            review: "This is a sample review text. It discusses the product or service in detail and gives insights about its pros and cons.",
            participants: 99,
            tags: ["活动", "社交", "健身"],
            timeElapsed: "3 days",
            distance: "300m",
            title: "有一起打球的吗？", // 示例标题
            showAvatar: true // 设置是否显示头像
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
