import SwiftUI
import Combine

struct HomeTabView: View {
    // MARK: - Properties
    @StateObject private var viewModel = HomeTabViewModel()
    @EnvironmentObject private var navigationManager: AppNavigationManager
    @State private var isNavBarVisible: Bool = true
    @State private var isAnimating: Bool = false
    var onMenuTap: () -> Void
    
    // 添加视图高度常量
    private let navBarHeight: CGFloat = 44
    private let searchBarHeight: CGFloat = 40
    private let searchBottomPadding: CGFloat = 8
    private let totalHeaderHeight: CGFloat = 92
    
    init(onMenuTap: @escaping () -> Void) {
        self.onMenuTap = onMenuTap
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            postsContent
            
            // 头部视图
            VStack(spacing: 1) {
                navigationBar
                
                SearchAndFilterView(search: $viewModel.search)
                    .padding(.vertical, 2)
                    .padding(.bottom, searchBottomPadding)
            }
            .frame(height: totalHeaderHeight)
            .background(Color.white)
            .offset(y: isNavBarVisible ? 0 : -totalHeaderHeight)
            .opacity(isNavBarVisible ? 1 : 0)
        }
        .background(Color.white)
    }
    
    private var navigationBar: some View {
        CustomNavigationBar(
            userLocationText: viewModel.userLocationText,
            onMenuTap: onMenuTap
        )
        .frame(height: navBarHeight)
    }
    
    private var postsContent: some View {
        TabStateScrollView(
            axis: .vertical,
            showsIndicator: true,
            onStateChange: { isVisible in
                handleVisibilityChange(isVisible)
            }
        ) {
            LazyVStack(spacing: 16) {
                // 添加固定高度的占位空间
                Color.clear
                    .frame(height: totalHeaderHeight)
                
                ForEach(viewModel.posts) { post in
                    LocationPostButton(post: post) {
                        navigationManager.navigate(to: .postDetail(post: post))
                    }
                    .id(post.id)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }
    
    private func handleVisibilityChange(_ isVisible: Bool) {
      
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.1)) {
            isNavBarVisible = isVisible
        }
        
        
    }
}

// MARK: - Supporting Views
struct CustomNavigationBar: View {
    let userLocationText: String
    let onMenuTap: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onMenuTap) {
                Image(uiImage: #imageLiteral(resourceName: "menu"))
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Button(action: {
                print("Location button tapped")
            }) {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                    Text(userLocationText)
                        .font(.caption2)
                        .lineLimit(1)
                }
                .foregroundColor(.black)
            }
        }
        .padding(.horizontal)
        .frame(height: 44)
        .background(Color.white)
    }
}
