import SwiftUI
import MapKit

// MARK: - ViewModel
final class ProfileViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var offset: CGFloat = 0
    @Published var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.7433, longitude: 139.8476),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )
    
    let userStats = UserStats(participantsCount: "1K+", viewedTopicsCount: "1M+")
    let userProfile = UserProfile(
        name: "liu ziyuan",
        description: "我是一个专注于前端开发的程序员",
        avatar: "sample1"
    )
    func handleEdit(_ item: ReviewItem) {
           // 处理编辑逻辑
           print("Editing item: \(item.id)")
       }
       
       func handleDelete(_ item: ReviewItem) {
           // 处理删除逻辑
           print("Deleting item: \(item.id)")
       }
    var publishedContent: [ReviewItem] = [
        ReviewItem(
            name: "John Doe",
            date: "2024-10-03",
            location: "東京都 葛飾区 立石",
            review: "This is a sample review text. It discusses the product or service in detail and gives insights about its pros and cons.",
            participants: 99,
            tags: ["活动", "社交", "健身"],
            timeElapsed: "3 days",
            distance: "300m",
            title: "有一起去吃中华料理的吗？"
        ),
        // Add more items as needed...
    ]
    
    var savedContent: [ReviewItem] = [
        ReviewItem(
            name: "John Doe",
            date: "2024-10-03",
            location: "東京都 葛飾区 立石",
            review: "This is a sample review text. It discusses the product or service in detail and gives insights about its pros and cons.",
            participants: 99,
            tags: ["活动", "社交", "健身"],
            timeElapsed: "1 Day",
            distance: "300m",
            title: "有一起去吃中华料理的吗？"
        )
    ]
}

// MARK: - Models
struct UserStats {
    let participantsCount: String
    let viewedTopicsCount: String
}

struct UserProfile {
    let name: String
    let description: String
    let avatar: String
}

struct ReviewItem: Identifiable {
    let id = UUID()
    let name: String
    let date: String
    let location: String
    let review: String
    let participants: Int
    let tags: [String]
    let timeElapsed: String
    let distance: String
    let title: String
}

// MARK: - Main View
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        ZStack {
            backgroundLayers
            
            ScrollView {
                LazyVStack(spacing: 10) {
                    MapOverviewSection(
                        cameraPosition: $viewModel.cameraPosition,
                        offset: viewModel.offset,
                        stats: viewModel.userStats
                    )
                    
                    UserProfileSection(profile: viewModel.userProfile)
                    
                    TabSelectionSection(selectedTab: $viewModel.selectedTab)
                    
                    ContentListSection(
                                           selectedTab: viewModel.selectedTab,
                                           publishedContent: viewModel.publishedContent,
                                           savedContent: viewModel.savedContent,
                                           onEdit: viewModel.handleEdit,    // 添加编辑处理
                                           onDelete: viewModel.handleDelete // 添加删除处理
                                       )
                }
            }
            .background(GeometryReader { proxy in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: proxy.frame(in: .named("scroll")).minY
                )
            })
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                viewModel.offset = offset
            }
            .coordinateSpace(name: "scroll")
        }
    }
    
    private var backgroundLayers: some View {
        ZStack {
            Map(position: $viewModel.cameraPosition)
                .edgesIgnoringSafeArea(.all)
                .opacity(0.3)
            
            LinearGradient(
                gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Supporting Views
struct MapOverviewSection: View {
    @Binding var cameraPosition: MapCameraPosition
    let offset: CGFloat
    let stats: UserStats
    
    var body: some View {
        Map(position: $cameraPosition)
            .frame(height: 200)
            .cornerRadius(20)
            .shadow(radius: 5)
            .overlay(StatisticsOverlay(stats: stats))
            .padding(.top, offset < 0 ? -offset : 0)
            .padding(.horizontal)
    }
}

struct StatisticsOverlay: View {
    let stats: UserStats
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                StatBox(title: "参加过我话题的人", value: stats.participantsCount)
                StatBox(title: "我浏览过的话题数", value: stats.viewedTopicsCount)
            }
        }
        .padding()
    }
}

struct StatBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.black)
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
        }
        .padding()
        .background(Color.white.opacity(0.6))
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}

struct UserProfileSection: View {
    let profile: UserProfile
    
    var body: some View {
        VStack(spacing: 8) {
            Image(profile.avatar)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .shadow(radius: 4)
                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
            
            Text(profile.name)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(profile.description)
                .font(.caption)
                .foregroundColor(.black)
                .padding(.horizontal)
        }
        .padding(.top, 10)
    }
}

struct TabSelectionSection: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            TabButtonRow(title: "我发布的", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            TabButtonRow(title: "我收藏的", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
        }
        .padding(.vertical, 10)
    }
}

struct TabButtonRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .black)
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
                .background(isSelected ? Color.black : Color.white)
                .cornerRadius(20)
                .clipShape(Capsule())
                .shadow(radius: isSelected ? 5 : 0)
        }
    }
}

struct ContentListSection: View {
    let selectedTab: Int
    let publishedContent: [ReviewItem]
    let savedContent: [ReviewItem]
    var onEdit: ((ReviewItem) -> Void)? = nil  // 添加默认值
    var onDelete: ((ReviewItem) -> Void)? = nil  // 添加默认值
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(selectedTab == 0 ? publishedContent : savedContent) { item in
                MyReviewRow(
                    data: ReviewRowData(
                        name: item.name,
                        date: item.date,
                        location: item.location,
                        review: item.review,
                        participants: item.participants,
                        tags: item.tags,
                        timeElapsed: item.timeElapsed,
                        distance: item.distance,
                        title: item.title,
                        showAvatar: true
                    ),
                    onEdit: { onEdit?(item) },
                    onDelete: { onDelete?(item) }
                )
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
