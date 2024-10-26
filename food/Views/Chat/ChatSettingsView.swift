import SwiftUI

// MARK: - Models
struct Member: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let imageName: String
}

// MARK: - ViewModel
final class ChatSettingsViewModel: ObservableObject {
    @Published var isTopChat = false
    @Published var members: [Member]
    
    init() {
        self.members = [
            Member(name: "Isabellaa s da s d", imageName: "sample1"),
            Member(name: "Martin", imageName: "sample2"),
            Member(name: "Shirley", imageName: "sample1"),
            Member(name: "David", imageName: "sample1"),
            Member(name: "Matilde", imageName: "sample1"),
            Member(name: "Eli", imageName: "sample1")
        ]
    }
}

// MARK: - Constants
private enum Layout {
    static let avatarSize: CGFloat = 40
    static let memberSpacing: CGFloat = 8
    static let cornerRadius: CGFloat = 10
    static let shadowRadius: CGFloat = 5
    static let iconSize: CGFloat = 20
    static let memberScrollHeight: CGFloat = 70
    
    static let shadowColor = Color.gray.opacity(0.2)
}

// MARK: - Main View
struct ChatSettingsView: View {
    @StateObject private var viewModel = ChatSettingsViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    MembersSection(members: viewModel.members)
                    SettingsSection(isTopChat: $viewModel.isTopChat)
                    DangerSection()
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        }
    }
}

// MARK: - Supporting Views
struct MembersSection: View {
    let members: [Member]
    
    var body: some View {
        HStack(alignment: .center) {
            OwnerAvatar()
            MembersList(members: members)
        }
        .padding(.vertical, 5)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Layout.shadowColor, radius: 10, x: 0, y: 5)
    }
}

struct OwnerAvatar: View {
    var body: some View {
        VStack {
            Image("sample1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: Layout.avatarSize, height: Layout.avatarSize)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                .shadow(radius: 3)
            
            Text("Owner")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.blue)
        }
        .frame(width: Layout.avatarSize)
        .padding(.leading, 5)
    }
}

struct MembersList: View {
    let members: [Member]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: Layout.memberSpacing) {
                ForEach(members) { member in
                    MemberView(member: member)
                }
            }
            .padding(.horizontal, 5)
        }
        .frame(height: Layout.memberScrollHeight)
    }
}

struct MemberView: View {
    let member: Member
    
    var body: some View {
        VStack {
            Image(member.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: Layout.avatarSize, height: Layout.avatarSize)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                .shadow(radius: 3)
            
            Text(member.name)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .frame(width: 50)
    }
}

struct SettingsSection: View {
    @Binding var isTopChat: Bool
    
    var body: some View {
        LazyVStack(spacing: 15) {
            SettingRow(icon: "pin.fill", title: "置顶聊天") {
                Toggle("", isOn: $isTopChat)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
            
            NavigationLink(destination: EditAnnouncementView()) {
                SettingRow(icon: "megaphone.fill", title: "修改公告") {
                    ChevronRight()
                }
            }
            
            SettingRow(icon: "square.and.arrow.up", title: "分享群聊") {
                ChevronRight()
            }
            .onTapGesture { /* 分享逻辑 */ }
            
            SettingRow(icon: "qrcode", title: "聊天室二维码") {
                ChevronRight()
            }
            .onTapGesture { /* 二维码逻辑 */ }
        }
    }
}

struct DangerSection: View {
    var body: some View {
        LazyVStack(spacing: 15) {
            SettingRow(icon: "trash.fill", title: "清空聊天记录", color: .gray) {
                ChevronRight()
            }
            .onTapGesture { /* 清空逻辑 */ }
            
            SettingRow(icon: "trash.circle.fill", title: "删除该聊天室", color: .red) {
                ChevronRight()
            }
            .onTapGesture { /* 删除逻辑 */ }
        }
    }
}

struct SettingRow<Content: View>: View {
    let icon: String
    let title: String
    let color: Color
    let content: () -> Content
    
    init(
        icon: String,
        title: String,
        color: Color = .gray,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.icon = icon
        self.title = title
        self.color = color
        self.content = content
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: Layout.iconSize))
            Text(title)
                .foregroundColor(color == .gray ? .black : color)
            Spacer()
            content()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(Layout.cornerRadius)
        .shadow(color: Layout.shadowColor, radius: Layout.shadowRadius, x: 0, y: 5)
    }
}

struct ChevronRight: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .foregroundColor(.gray)
    }
}

// MARK: - Preview
struct ChatSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChatSettingsView()
                .previewDisplayName("Light Mode")
            
            ChatSettingsView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
