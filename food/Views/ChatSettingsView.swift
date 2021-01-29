import SwiftUI

// Member model
struct Member: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
}

// 主页面视图，包括成员列表和聊天室设置
struct ChatSettingsView: View {
    
    @State private var members: [Member] = [
        Member(name: "Isabellaa s da s d", imageName: "sample1"),
        Member(name: "Martin", imageName: "sample2"),
        Member(name: "Shirley", imageName: "sample1"),
        Member(name: "David", imageName: "sample1"),
        Member(name: "Matilde", imageName: "sample1"),
        Member(name: "Eli", imageName: "sample1")
    ]
    
    @State private var isTopChat = false // 聊天室置顶状态
    @State private var showAnnouncement = false
    
    @State private var showQRCode = false
    @State private var showGroupName = false
    @State private var showNickname = false
    @State private var showClearChat = false
    @State private var showDeleteChat = false
    
    var body: some View {
        VStack {
            // 固定显示群主头像
           
            
            // 设置项列表
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .center) { // 保证群主和成员在同一高度上
                    VStack {
                        Image("sample1") // 群主头像
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40) // 进一步缩小群主头像大小
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.blue, lineWidth: 2) // 蓝色边框标记为群主
                                    .shadow(radius: 3)
                            )
                        
                        Text("Owner") // 群主名字
                            .font(.caption2) // 调整字体
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                    .frame(width: 40, height: 40) // 调整群主头像区域的宽度
                    .padding(.leading, 5) // 适当减少左侧边距

                    // 可滚动的成员列表
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) { // 缩小头像间隔
                            ForEach(members) { member in
                                VStack {
                                    // 圆形头像
                                    Image(member.imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 40, height: 40) // 进一步缩小成员头像大小
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 1.5) // 白色边框
                                                .shadow(radius: 3) // 轻微阴影
                                        )

                                    // 成员名字
                                    Text(member.name)
                                        .font(.caption2) // 使用较小字体
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                                .frame(width: 50) // 每个成员设置固定宽度
                            }
                        }
                        .padding(.horizontal, 5) // 添加内边距
                    }
                    .frame(height: 60) // 调整滚动视图的高度
                }
                .padding(.vertical, 5)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5) // 添加阴影
                // 聊天室置顶
                HStack {
                    Image(systemName: "pin.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 20))
                    Toggle("置顶聊天", isOn: $isTopChat)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
                
                // 修改公告
                HStack {
                    Image(systemName: "megaphone.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 20))
                    Text("修改公告")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
                .onTapGesture {
                    // 修改公告的逻辑
                }
                
                // 聊天室二维码
                HStack {
                    Image(systemName: "qrcode")
                        .foregroundColor(.gray)
                        .font(.system(size: 20))
                    Text("聊天室二维码")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
                .onTapGesture {
                    // 聊天室二维码的逻辑
                }
                
                // 群聊名称
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 20))
                    Text("群聊名称")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
                .onTapGesture {
                    // 修改群聊名称的逻辑
                }
                
                // 我在本群的昵称
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 20))
                    Text("我在本群的昵称")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
                .onTapGesture {
                    // 修改本群昵称的逻辑
                }
                
                // 清空聊天记录
                HStack {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 20))
                    Text("清空聊天记录")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
                .onTapGesture {
                    // 清空聊天记录的逻辑
                }
                
                // 删除该聊天室
                HStack {
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 20))
                    Text("删除该聊天室")
                        .foregroundColor(.red)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
                .onTapGesture {
                    // 删除聊天室的逻辑
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
        .padding(.top, 10)
        .padding(.bottom, 10)
    }
}

// Preview
struct ChatSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatSettingsView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
