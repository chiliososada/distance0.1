import SwiftUI



// MARK: - 主视图
struct MyReviewRow: View {
    private let data: LocationPost
    private let onEdit: () -> Void
    private let onDelete: () -> Void
    
    init(data: LocationPost, onEdit: @escaping () -> Void = {}, onDelete: @escaping () -> Void = {}) {
        self.data = data
        self.onEdit = onEdit
        self.onDelete = onDelete
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ReviewHeader(
                name: data.authorName,
                date: data.publishDate,
                timeElapsed: data.postedTime,
                showAvatar: true,
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
                participants: data.participantsCount,
                location: data.locationName
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
            Text(data.title ?? "")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .lineLimit(2)
            
            Text(data.content)
                .font(.footnote)
                .foregroundColor(.black)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
}
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



// MARK: - 预览
struct MyReviewRow_Previews: PreviewProvider {
    static var previews: some View {
        MyReviewRow(
            data: LocationPost(
                title: "有一起打球的的吗",
                content: "今天早上我有个计划，就是去入管局办理一些手续。",
                authorName: "劉子源",
                locationName: "東京都 葛飾区 立石",
                latitude: 35.681236,
                longitude: 139.767125,
                imageNames: ["sample1"],
                avatarImage: "sample2",
                tags: ["娱乐", "运动", "篮球"],
                participantsCount: 99,
                postedTime: "10 mins",
                remainingDays: "3 days",
                publishDate: "2024-10-01",
                joinedCount: "75＋",
                cachedDistance: 300
            ),
            onEdit: { print("Edit tapped") },
            onDelete: { print("Delete tapped") }
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
