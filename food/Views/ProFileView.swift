import SwiftUI
import MapKit

struct ProfileView: View {
    @State private var selectedTab = 0 // 0 表示“我发布的”，1 表示“我收藏的”
    @State private var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.7433, longitude: 139.8476), // 葛饰区的坐标
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // 建议适中的缩放级别
       ))
    @State private var offset: CGFloat = 0.0 // 用于检测滚动偏移量

    var body: some View {
        ZStack {
            // 使用地图作为背景，同时有一定的透明度
            Map(position: $cameraPosition)
                         .edgesIgnoringSafeArea(.all)
                         .opacity(0.3) // 控制地图的透明度，让内容更突出
            // 背景颜色渐变
            LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.white]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 10) {
                    // 地图和地理信息
                    Map(position: $cameraPosition)
                        .frame(height: 200)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        .overlay(
                            VStack {
                                HStack(spacing: 20) {
                                    VStack {
                                        Text("参加过我话题的人")
                                            .font(.caption)
                                            .foregroundColor(.black)
                                        Text("1K+")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.6)) // 调整背景的透明度
                                    .cornerRadius(15)
                                    .shadow(radius: 3)
                                    
                                    VStack {
                                        Text("我浏览过的话题数")
                                            .font(.caption)
                                            .foregroundColor(.black)
                                        Text("1M+")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.6)) // 调整背景的透明度
                                    .cornerRadius(15)
                                    .shadow(radius: 3)
                                }}
                            .padding()
                        )
                        .padding(.top, offset < 0 ? -offset : 0) // 地图随着滚动固定
                        .padding(.horizontal)

                    // 头像和个人信息
                    VStack(spacing: 8) {
                        Image("sample1") // 替换为实际头像图片
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .shadow(radius: 4) // 增加头像的阴影效果
                            .overlay(
                                Circle().stroke(Color.gray, lineWidth: 2)
                            )
                        
                        Text("liu ziyuan")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text("我是一个专注于前端开发的程序员")
                            .font(.caption)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                    }
                    .padding(.top, 10)

                    // 选项卡选择部分 (我发布的, 我收藏的)
                    HStack {
                        // “我发布的”按钮
                        Button(action: {
                            selectedTab = 0 // 切换到 "我发布的"
                        }) {
                            Text("我发布的")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(selectedTab == 0 ? .white : .black)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 20)
                                .background(selectedTab == 0 ? Color.black : Color.white)
                                .cornerRadius(20)
                                .clipShape(Capsule())
                                .shadow(radius: selectedTab == 0 ? 5 : 0)
                        }
                        
                        // “我收藏的”按钮
                        Button(action: {
                            selectedTab = 1 // 切换到 "我收藏的"
                        }) {
                            Text("我收藏的")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(selectedTab == 1 ? .white : .black)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 20)
                                .background(selectedTab == 1 ? Color.black : Color.white)
                                .cornerRadius(20)
                                .clipShape(Capsule())
                                .shadow(radius: selectedTab == 1 ? 5 : 0)
                        }
                        
                        
                    }
                    .padding(.vertical, 10)

                    // 列表显示
                    if selectedTab == 0 {
                        // 显示“我发布的”内容
                        VStack(spacing: 12) {
                            MyReviewRow(
                                name: "John Doe",
                                date: "2024-10-03",
                                location: "東京都 葛飾区 立石",
                                review: "This is a sample review text. It discusses the product or service in detail and gives insights about its pros and cons.",
                                participants: 99,
                                tags: ["活动", "社交", "健身"],
                                timeElapsed: "3 days",
                                distance: "300m",
                                title: "有一起去吃中华料理的吗？", // 示例标题
                                showAvatar: true // 设置是否显示头像
                            )
                            MyReviewRow(
                                name: "John Doe",
                                date: "2024-10-03",
                                location: "東京都 葛飾区 立石",
                                review: "This is a sample review text. It discusses the product or service in detail and gives insights about its pros and cons.",
                                participants: 99,
                                tags: ["活动", "社交", "健身"],
                                timeElapsed: "1 day",
                                distance: "300m",
                                title: "用户评价", // 示例标题
                                showAvatar: true // 设置是否显示头像
                            )
                            MyReviewRow(
                                name: "John Doe",
                                date: "2024-10-03",
                                location: "東京都 葛飾区 立石",
                                review: "This is a sample review text. It discusses the product or service in detail and gives insights about its pros and cons.",
                                participants: 99,
                                tags: ["活动", "社交", "健身"],
                                timeElapsed: "1 day",
                                distance: "300m",
                                title: "用户评价", // 示例标题
                                showAvatar: true // 设置是否显示头像
                            )
                            MyReviewRow(
                                name: "John Doe",
                                date: "2024-10-03",
                                location: "東京都 葛飾区 立石",
                                review: "This is a sample review text. It discusses the product or service in detail and gives insights about its pros and cons.",
                                participants: 99,
                                tags: ["活动", "社交", "健身"],
                                timeElapsed: "10 mins ago",
                                distance: "300m",
                                title: "用户评价", // 示例标题
                                showAvatar: true // 设置是否显示头像
                            )
                        }
                        .padding(.top, 8)
                    } else if selectedTab == 1 {
                        // 显示“我收藏的”内容
                        VStack(spacing: 12) {
                            MyReviewRow(
                                name: "John Doe",
                                date: "2024-10-03",
                                location: "東京都 葛飾区 立石",
                                review: "This is a sample review text. It discusses the product or service in detail and gives insights about its pros and cons.",
                                participants: 99,
                                tags: ["活动", "社交", "健身"],
                                timeElapsed: "1 Day",
                                distance: "300m",
                                title: "有一起去吃中华料理的吗？", // 示例标题
                                showAvatar: true // 设置是否显示头像
                            )
                        }
                        .padding(.top, 10)
                    }
                }
            }
        }
    }
}


// 评论行视图


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
