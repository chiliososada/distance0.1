import SwiftUI
import MapKit


// MARK: - Main View
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        ZStack {
            // 背景层
            if let mapImage = viewModel.mapImage {
                Image(uiImage: mapImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.3)
            }
            
            LinearGradient(
                gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 10) {
                    //Color.clear.frame(height: 44)
                    MapSnapshotSection(
                                         mapImage: viewModel.mapPreviewImage,
                                         isLoading: viewModel.isLoadingMap,
                                         offset: viewModel.offset,
                                         profile: viewModel.userProfile
                                     )
                    
                    UserProfileSection(profile: viewModel.userProfile)
                    
                    TabSelectionSection(selectedTab: $viewModel.selectedTab)
                    
                    ContentListSection(
                        selectedTab: viewModel.selectedTab,
                        publishedContent: viewModel.publishedContent,
                        savedContent: viewModel.savedContent,
                        onEdit: viewModel.handleEdit,
                        onDelete: viewModel.handleDelete
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
}

// MARK: - Supporting Views
struct MapSnapshotSection: View {
    let mapImage: UIImage?
    let isLoading: Bool
    let offset: CGFloat
    let profile: UserProfile
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .frame(height: 200)
            } else if let mapImage = mapImage {
                Image(uiImage: mapImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .cornerRadius(20)
                    .shadow(radius: 5)
            }
            
            StatisticsOverlay(stats: profile.stats)
        }
        .padding(.top, offset < 0 ? -offset : 0)
        .padding(.horizontal)
        .padding(.top, 60)
    }
}



struct StatisticsOverlay: View {
    let stats: UserProfile.UserStats
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                StatBox(title: "参加过我话题的人", value: stats.formattedParticipantsCount)
                StatBox(title: "我浏览过的话题数", value: stats.formattedViewedTopicsCount)
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
            Image(profile.avatarUrl ?? "sample1") // 使用 avatarUrl，提供默认值
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
            
            Text(profile.userName)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(profile.bio ?? "")
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
        }
    }
}

struct ContentListSection: View {
    let selectedTab: Int
    let publishedContent: [LocationPost]
    let savedContent: [LocationPost]
    var onEdit: ((LocationPost) -> Void)? = nil
    var onDelete: ((LocationPost) -> Void)? = nil
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(selectedTab == 0 ? publishedContent : savedContent) { item in
                MyReviewRow(
                    data: item,
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
