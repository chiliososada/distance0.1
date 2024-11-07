import SwiftUI

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
    @StateObject private var viewModel: ChatSettingsViewModel
        
        init(chatRoom: ChatRoom) {
            _viewModel = StateObject(wrappedValue: ChatSettingsViewModel(chatRoom: chatRoom))
        }
        
        var body: some View {
            NavigationView {
                ScrollView {
                    if case .loading = viewModel.viewState {
                        ProgressView()
                            .scaleEffect(1.5)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    } else {
                        LazyVStack(alignment: .leading, spacing: 20) {
                            MembersSection(members: viewModel.members)  // 直接传递 members 数组
                            SettingsSection(viewModel: viewModel)
                            DangerSection(viewModel: viewModel)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                }
            }
            .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {
                Button("取消", role: .cancel) { }
                Button("确定", role: .destructive) {
                    viewModel.confirmAction?()  // 调用确认操作
                }
            }    
    }
}

// MARK: - Supporting Views
struct MembersSection: View {
    let members: [Member]  // 修改：使用数组类型
    
    var body: some View {
        HStack(alignment: .center) {
            if let owner = members.first(where: { $0.role == .owner }) {
                OwnerAvatar(member: owner)  // 添加参数
            }
            MembersList(members: members)  // 传递整个数组
        }
        .padding(.vertical, 5)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Layout.shadowColor, radius: 10, x: 0, y: 5)
    }
}

struct OwnerAvatar: View {
    let member: Member  // 添加 member 参数
    
    var body: some View {
        VStack {
            Image(member.avatar)  // 使用 avatar 而不是固定图片
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: Layout.avatarSize, height: Layout.avatarSize)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                .shadow(radius: 3)
            
            Text(member.name)  // 显示实际的名字
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.blue)
        }
        .frame(width: Layout.avatarSize)
        .padding(.leading, 5)
    }
}

struct MembersList: View {
    let members: [Member]  // 修改：使用正确的类型
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: Layout.memberSpacing) {
                ForEach(members.filter { $0.role != .owner }) { member in  // 过滤掉群主
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
            Image(member.avatar)  // 使用 avatar 而不是 imageName
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: Layout.avatarSize, height: Layout.avatarSize)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                .shadow(radius: 3)
            
            VStack(spacing: 2) {
                Text(member.name)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(getRoleText(member.role))  // 添加角色显示
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 50)
    }
    
    private func getRoleText(_ role: Member.MemberRole) -> String {
        switch role {
        case .owner:
            return "群主"
        case .admin:
            return "管理员"
        case .member:
            return "成员"
        }
    }
}

struct SettingsSection: View {
    @ObservedObject var viewModel: ChatSettingsViewModel
    
    var body: some View {
        LazyVStack(spacing: 15) {
            SettingRow(icon: "pin.fill", title: "置顶聊天") {
                Toggle("", isOn: $viewModel.isTopChat)
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
            .onTapGesture { viewModel.handleAction(.shareChat) }
            
            SettingRow(icon: "qrcode", title: "聊天室二维码") {
                ChevronRight()
            }
            .onTapGesture { viewModel.handleAction(.showQRCode) }
        }
    }
}

struct DangerSection: View {
    @ObservedObject var viewModel: ChatSettingsViewModel
    
    var body: some View {
        LazyVStack(spacing: 15) {
            SettingRow(icon: "trash.fill", title: "清空聊天记录", color: .gray) {
                ChevronRight()
            }
            .onTapGesture { viewModel.handleAction(.clearChat) }
            
            SettingRow(icon: "trash.circle.fill", title: "删除该聊天室", color: .red) {
                ChevronRight()
            }
            .onTapGesture { viewModel.handleAction(.deleteChat) }
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


struct ChatSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatSettingsView(
            chatRoom: ChatRoom(
                name: "Sample Chat",
                type: .group,
                avatar: "sample1",
                lastMessage: Message(
                    id: UUID(),
                    sender: Member(
                        id: UUID(),
                        name: "Alice",
                        avatar: "sample1",
                        role: .member
                    ),
                    content: .text("Last message"),
                    timestamp: Date(),
                    status: .sent
                ),
                members: [
                    Member(
                        id: UUID(),
                        name: "Bob",
                        avatar: "sample1",
                        role: .owner
                    ),
                    Member(
                        id: UUID(),
                        name: "Alice",
                        avatar: "sample2",
                        role: .member
                    ),
                    Member(
                        id: UUID(),
                        name: "Charlie",
                        avatar: "sample1",
                        role: .admin
                    )
                ],
                announcement: Announcement(
                    id: UUID(),
                    content: "Welcome to the group!",
                    timestamp: Date(),
                    link: nil,
                    creator: Member(
                        id: UUID(),
                        name: "Bob",
                        avatar: "sample1",
                        role: .owner
                    )
                )
            )
        )
    }
}
