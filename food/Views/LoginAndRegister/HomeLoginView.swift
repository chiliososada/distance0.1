import SwiftUI

// MARK: - Constants
private enum Layout {
    static let buttonWidth: CGFloat = 100
    static let buttonHeight: CGFloat = 40
    static let cornerRadius: CGFloat = 10
    static let cardWidth: CGFloat = 300
    static let iconSize: CGFloat = 12
    static let spacing: CGFloat = 20
    
    static let shadowRadius: CGFloat = 7
    static let shadowY: CGFloat = 4
    
    enum Padding {
        static let vertical: CGFloat = 15
        static let horizontal: CGFloat = 15
        static let top: CGFloat = 100
    }
}

// MARK: - View Models
final class ProfileCardViewModel: ObservableObject {
    let name: String
    let location: String
    let message: String
    let tags: [String]
    let distance: String
    let participants: String
    let time: String
    
    init(
        name: String,
        location: String,
        message: String,
        tags: [String],
        distance: String,
        participants: String,
        time: String
    ) {
        self.name = name
        self.location = location
        self.message = message
        self.tags = tags
        self.distance = distance
        self.participants = participants
        self.time = time
    }
    
    static let examples = [
        ProfileCardViewModel(
            name: "liu ziyuan",
            location: "東京都 葛飾区 立石",
            message: "一起去唱歌🎤吧！",
            tags: ["#中古", "#兼职", "#手机"],
            distance: "300m",
            participants: "99人",
            time: "10 mins"
        ),
        ProfileCardViewModel(
            name: "liu ziyuan",
            location: "東京都 葛飾区 立石",
            message: "一起去跳舞💃吧！",
            tags: ["#中古", "#兼职", "#手机"],
            distance: "300m",
            participants: "99人",
            time: "10 mins"
        )
    ]
}

// MARK: - Main View
struct HomeLoginView: View {
    let velocity: CGFloat = 50
    @EnvironmentObject var tabBarManager: TabBarManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: Layout.spacing * 2) {
                AnimationSection()
                TitleSection()
                ButtonSection()
                MarqueeSection()
            }
            .navigationDestination(for: String.self) { route in
                destinationView(for: route)
            }
        }
    }
    
    private func destinationView(for route: String) -> some View {
        Group {
            switch route {
            case "register":
                RegisterView()
                    .environmentObject(tabBarManager)
            case "login":
                LoginInputView(showBackButton: true)
                    .environmentObject(tabBarManager)
            default:
                EmptyView()
            }
        }
    }
}

// MARK: - Supporting Views
private struct AnimationSection: View {
    var body: some View {
        VerticalLineAnimationView()
            .frame(height: 200)
            .padding(.top, Layout.Padding.top)
    }
}

private struct TitleSection: View {
    var body: some View {
        Text("参加你周围正在发生的新鲜事。")
            .bold()
    }
}

private struct ButtonSection: View {
    var body: some View {
        HStack(spacing: Layout.spacing) {
            NavigationButton(
                title: "注册",
                route: "register",
                style: .outlined
            )
            
            NavigationButton(
                title: "登陆",
                route: "login",
                style: .filled
            )
        }
        .padding(.bottom, 10)
    }
}

private struct NavigationButton: View {
    let title: String
    let route: String
    let style: ButtonStyle
    
    enum ButtonStyle {
        case outlined, filled
    }
    
    var body: some View {
        NavigationLink(value: route) {
            Text(title)
                .frame(width: Layout.buttonWidth, height: Layout.buttonHeight)
                .background(style == .filled ? Color.black : Color.white)
                .foregroundColor(style == .filled ? .white : .black)
                .cornerRadius(Layout.cornerRadius)
                .if(style == .outlined) { view in
                    view.overlay(
                        RoundedRectangle(cornerRadius: Layout.cornerRadius)
                            .stroke(Color.black, lineWidth: 1)
                    )
                }
        }
    }
}

private struct MarqueeSection: View {
    var body: some View {
        Marquee(targetVelocity: 30) {
            HStack(spacing: 10) {
                ForEach(ProfileCardViewModel.examples, id: \.message) { viewModel in
                    ProfileCard(viewModel: viewModel)
                }
            }
            .padding(.horizontal)
        }
        .marqueeStyle()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .padding(.bottom, 80)
    }
}

// MARK: - Profile Card
struct ProfileCard: View {
    let viewModel: ProfileCardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HeaderSection(name: viewModel.name, location: viewModel.location)
            MessageSection(message: viewModel.message)
            TagsSection(tags: viewModel.tags)
            FooterSection(
                participants: viewModel.participants,
                time: viewModel.time,
                distance: viewModel.distance
            )
        }
        .padding(.horizontal, Layout.Padding.horizontal)
        .padding(.vertical, Layout.Padding.vertical)
        .cardStyle()
    }
}

// MARK: - Profile Card Sections
private struct HeaderSection: View {
    let name: String
    let location: String
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.caption)
                    .foregroundColor(.black)
                    .bold()
                
                LocationRow(location: location)
            }
            Spacer()
        }
    }
}

private struct LocationRow: View {
    let location: String
    
    var body: some View {
        HStack {
            Image(systemName: "location.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: Layout.iconSize, height: Layout.iconSize)
                .foregroundColor(.gray)
            
            Text(location)
                .font(.caption2)
                .foregroundColor(.gray)
                .lineLimit(1)
        }
    }
}

private struct MessageSection: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.black)
    }
}

private struct TagsSection: View {
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

private struct FooterSection: View {
    let participants: String
    let time: String
    let distance: String
    
    var body: some View {
        HStack(spacing: 8) {
            InfoRow(icon: "person.fill", text: participants)
            InfoRow(icon: "clock.fill", text: time)
            Spacer()
            Text("距离我 \(distance)")
                .font(.caption)
                .foregroundColor(.black)
        }
    }
}

private struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: Layout.iconSize, height: Layout.iconSize)
                .foregroundColor(.gray)
            
            Text(text)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - View Modifiers
extension View {
    func marqueeStyle() -> some View {
        self.mask(
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .clear, location: 0.0),
                    .init(color: .black, location: 0.2),
                    .init(color: .black, location: 0.8),
                    .init(color: .clear, location: 1.0)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
    
    func cardStyle() -> some View {
        self
            .background(Color.white)
            .cornerRadius(Layout.cornerRadius)
            .shadow(
                color: Color.black.opacity(0.12),
                radius: Layout.shadowRadius,
                x: 0,
                y: Layout.shadowY
            )
            .frame(width: Layout.cardWidth)
    }
    
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Preview
struct HomeLoginView_Previews: PreviewProvider {
    static var previews: some View {
        HomeLoginView()
            .environmentObject(TabBarManager())
    }
}
