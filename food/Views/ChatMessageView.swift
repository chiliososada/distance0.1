import SwiftUI

// 自定义气泡形状
struct BubbleShape: Shape {
    var isCurrentUser: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        if isCurrentUser {
            // 当前用户的气泡在右侧
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addRoundedRect(in: CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height), cornerSize: CGSize(width: 15, height: 15))
        } else {
            // 非当前用户的气泡在左侧
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addRoundedRect(in: CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height), cornerSize: CGSize(width: 15, height: 15))
        }
        
        return path
    }
}

// 消息视图，根据发布者在左侧或右侧显示
struct MessageView: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer() // 当前用户消息在右侧显示
                
                VStack(alignment: .trailing, spacing: 4) {
                    // 显示用户名
                    Text(message.userName)
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    // 消息内容使用自定义的气泡形状
                    Text(message.text)
                        .padding()
                        .background(Color.blue.opacity(0.4))
                        .clipShape(BubbleShape(isCurrentUser: true))
                }
                .padding(.horizontal, 5) // 缩小水平 padding
                
                Image(message.avatar)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .padding(.trailing, 3) // 减小头像右侧间距
                
            } else {
                Image(message.avatar)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .padding(.leading, 3) // 减小头像左侧间距
                
                VStack(alignment: .leading, spacing: 4) {
                    // 显示用户名
                    Text(message.userName)
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    // 消息内容使用自定义的气泡形状
                    Text(message.text)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(BubbleShape(isCurrentUser: false))
                }
                .padding(.horizontal, 5) // 缩小水平 padding
                
                Spacer() // 其他用户消息在左侧显示
            }
        }
        .padding(.vertical, 5)
    }
}

// 模拟数据模型
struct Message: Identifiable {
    let id: Int
    let userName: String
    let text: String
    let avatar: String
}

// Add Preview
struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 预览当前用户发布的消息
            MessageView(message: Message(id: 1, userName: "Me", text: "This is my message!", avatar: "sample1"), isCurrentUser: true)
                .previewLayout(.sizeThatFits)
                .padding()
            
            // 预览其他用户发布的消息
            MessageView(message: Message(id: 2, userName: "Alice", text: "Hi there! I'm Alice.", avatar: "sample2"), isCurrentUser: false)
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}
