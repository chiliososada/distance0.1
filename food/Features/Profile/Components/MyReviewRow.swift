import SwiftUI
// MARK: - 子组件
struct ReviewAvatar: View {
    let avatarImage: String  // 添加头像图片名称参数
    var body: some View {
        Image(avatarImage)
            .resizable()
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .shadow(radius: 4)
    }
}

struct ReviewTag: View {
    let text: String
    
    var body: some View {
        Text("#\(text)")
            .font(.caption)
            .foregroundColor(.blue)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
    }
}

struct ReviewHeader: View {
    let name: String
    let date: String
    let timeElapsed: String
    let showAvatar: Bool
    let avatarImage: String
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            if showAvatar {
                ReviewAvatar(avatarImage: avatarImage)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                Text(date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            timeAndOptionsMenu
        }
    }
    
    private var timeAndOptionsMenu: some View {
        HStack {
            Image(systemName: "clock.arrow.circlepath")
                .foregroundColor(.gray)
            Text(timeElapsed)
                .font(.caption)
                .foregroundColor(.gray)
            
            Menu {
                Button(action: onEdit) {
                    Label("编辑", systemImage: "pencil")
                }
                
                Button(action: onDelete) {
                    Label("删除", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
                    .padding(.leading, 10)
            }
        }
    }
}

struct ReviewFooter: View {
    let participants: Int
    let location: String
    
    var body: some View {
        HStack {
            participantsView
            Spacer()
            locationView
        }
    }
    
    private var participantsView: some View {
        HStack {
            Image(systemName: "person.2.fill")
                .foregroundColor(.gray)
            Text("\(participants) 人")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    private var locationView: some View {
        HStack {
            Image(systemName: "mappin.and.ellipse")
                .foregroundColor(.gray)
            Text(location)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - 主视图
struct MyReviewRow: View {
    private let data: ReviewItem
    private let onEdit: () -> Void
    private let onDelete: () -> Void
    
    init(data: ReviewItem, onEdit: @escaping () -> Void = {}, onDelete: @escaping () -> Void = {}) {
        self.data = data
        self.onEdit = onEdit
        self.onDelete = onDelete
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ReviewHeader(
                name: data.name,
                date: data.date,
                timeElapsed: data.timeElapsed,
                showAvatar: data.showAvatar,
                avatarImage: data.avatarImage,
                onEdit: onEdit,
                onDelete: onDelete
            )
            
            titleAndReview
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(data.tags, id: \.self) { tag in
                        ReviewTag(text: tag)
                    }
                }
            }
            
            ReviewFooter(
                participants: data.participants,
                location: data.location
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
        )
        .padding(.horizontal)
    }
    
    private var titleAndReview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(data.title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .lineLimit(2)
            
            Text(data.review)
                .font(.footnote)
                .foregroundColor(.black)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
}

// MARK: - 预览
struct MyReviewRow_Previews: PreviewProvider {
    static var previews: some View {
        MyReviewRow(
            data: ReviewItem(
                name: "John Doe",
                date: "2024-10-03",
                location: "東京都 葛飾区 立石",
                review: "This is a sample review text. It discusses the product or service in detail and gives insights about its pros and cons.",
                participants: 99,
                tags: ["活动", "社交", "健身"],
                timeElapsed: "3 days",
                distance: "300m",
                title: "有一起打球的吗？",
                showAvatar: true,
                avatarImage: "sample1"  
            ),
            onEdit: { print("Edit tapped") },
            onDelete: { print("Delete tapped") }
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
