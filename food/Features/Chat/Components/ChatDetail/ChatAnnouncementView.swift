import SwiftUI

// MARK: - View Model
final class AnnouncementViewModel: ObservableObject {
    @Published var announcement: Announcement
    
    struct Announcement {
        let time: String
        let title: String
        let link: String
        
        static let sample = Announcement(
            time: "15:00",
            title: "Exclusive shirt for 15 minutes.",
            link: "www.Nike.com/AJPicard"
        )
    }
    
    init(announcement: Announcement = .sample) {
        self.announcement = announcement
    }
}

// MARK: - Constants
private enum Layout {
    static let spacing: CGFloat = 4
    static let padding: CGFloat = 8
    static let cornerRadius: CGFloat = 12
    static let borderWidth: CGFloat = 1

    static let colors = ColorScheme()
    
    struct ColorScheme {
        let text = Color.black
        let background = Color.white
        let border = Color.black
    }
}

// MARK: - Main View
struct AnnouncementView: View {
    @StateObject private var viewModel: AnnouncementViewModel
    
    init(announcement: AnnouncementViewModel.Announcement = .sample) {
        _viewModel = StateObject(wrappedValue: AnnouncementViewModel(announcement: announcement))
    }
    
    var body: some View {
        contentView
            .frame(maxWidth: .infinity)
            .modifier(AnnouncementStyle())
    }
    
    private var contentView: some View {
        VStack(spacing: Layout.spacing) {
            AnnouncementTimeView(time: viewModel.announcement.time)
            AnnouncementTitleView(title: viewModel.announcement.title)
            LinkView(link: viewModel.announcement.link)
        }
        .padding(Layout.padding)
    }
}

// MARK: - Supporting Views
private struct AnnouncementTimeView: View {
    let time: String
    
    var body: some View {
        Text(time)
            .font(.system(size: 24, weight: .bold)) // 缩小字体
            .foregroundColor(Layout.colors.text)
    }
}

private struct AnnouncementTitleView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.subheadline) // 缩小次要文本
            .foregroundColor(Layout.colors.text)
    }
}

private struct LinkView: View {
    let link: String
    
    var body: some View {
        Text(link)
            .font(.footnote) // 链接文本更小
            .foregroundColor(Layout.colors.text)
    }
}

// MARK: - Style Modifier
private struct AnnouncementStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Layout.colors.background)
            .cornerRadius(Layout.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Layout.cornerRadius)
                    .stroke(Layout.colors.border, lineWidth: Layout.borderWidth)
            )
            .padding(.horizontal)
    }
}

// MARK: - Preview
struct AnnouncementView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Light Mode Preview
            AnnouncementView()
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Light Mode")
            
            // Dark Mode Preview
            AnnouncementView()
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
            
            // Custom Announcement Preview
            AnnouncementView(
                announcement: .init(
                    time: "16:30",
                    title: "Special Event Coming Soon",
                    link: "www.example.com/event"
                )
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Custom Content")
        }
    }
}
