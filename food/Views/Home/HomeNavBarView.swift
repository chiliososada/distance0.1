import SwiftUI

// MARK: - View Model
final class HomeNavBarViewModel: ObservableObject {
    @Published var location: String = "東京都 葛飾区 立石"
    
    // 处理菜单点击
    func handleMenuTap() {
        // 可以添加防抖动逻辑
        print("Menu tapped")
    }
}

// MARK: - Constants
private enum NavBarConstants {
    static let iconSize: CGFloat = 12
    static let horizontalPadding: CGFloat = 16
    static let verticalPadding: CGFloat = 8
    
    enum Images {
        static let menuImage = "menu"
        static let locationPin = "mappin.circle.fill"
    }
}

// MARK: - Main View
struct HomeNavBarView: View {
    @StateObject private var viewModel = HomeNavBarViewModel()
    
    var body: some View {
        content
            .padding(.horizontal, NavBarConstants.horizontalPadding)
            .padding(.vertical, NavBarConstants.verticalPadding)
    }
    
    private var content: some View {
        HStack(spacing: 12) {
            menuButton
            Spacer()
            locationInfo
        }
    }
}

// MARK: - Subviews
private extension HomeNavBarView {
    var menuButton: some View {
        Button(action: viewModel.handleMenuTap) {
            Image(uiImage: UIImage(named: NavBarConstants.Images.menuImage) ?? UIImage())
                .renderingMode(.template)
                .foregroundColor(.black)
        }
        .buttonStyle(NavBarButtonStyle())
    }
    
    var locationInfo: some View {
        HStack(spacing: 4) {
            LocationIcon()
            LocationText(text: viewModel.location)
        }
    }
}

// MARK: - Supporting Views
struct LocationIcon: View {
    var body: some View {
        Image(systemName: NavBarConstants.Images.locationPin)
            .resizable()
            .scaledToFit()
            .frame(width: NavBarConstants.iconSize,
                  height: NavBarConstants.iconSize)
            .foregroundColor(.gray)
    }
}

struct LocationText: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption2)
            .foregroundColor(.gray)
            .lineLimit(1)
            .truncationMode(.tail)
    }
}

// MARK: - Custom Button Style
struct NavBarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview Provider
struct HomeNavBarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 亮色模式预览
            HomeNavBarView()
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Light Mode")
            
            // 深色模式预览
            HomeNavBarView()
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
            
            // 不同设备尺寸预览
            HomeNavBarView()
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDevice("iPhone SE (3rd generation)")
                .previewDisplayName("iPhone SE")
        }
    }
}
