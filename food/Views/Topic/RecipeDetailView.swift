import SwiftUI

struct RecipeDetailView: View {
    let recipe: RecommendedRecipe // This matches the data structure
    @State private var currentImageIndex = 0 // Track the current image index
    @Environment(\.presentationMode) var presentationMode // For manually dismissing the view

    @State private var isPressed = false // 用于控制按钮缩放的状态
    @State private var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect() // 定时器
                  
    
    @EnvironmentObject var tabBarManager: TabBarManager
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 使用 ZStack 来处理图片和布局的叠加
                    ZStack(alignment: .top) {
                        TabView(selection: $currentImageIndex) {
                            ForEach(0..<recipe.imageNames.count, id: \.self) { index in
                                Image(recipe.imageNames[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width)
                                    .clipped()
                                    .clipShape(RoundedCorner(radius: 30, corners: [.bottomLeft, .bottomRight])
                                                 )
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Disable default page dots
                        .frame(height: 450) // Fixed height for image scrolling
                        .edgesIgnoringSafeArea(.all)
                        
                        
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss() // Go back to the previous view
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.title3) // Smaller font size
                                    .foregroundColor(.black)
                                    .padding(9) // Smaller padding
                                    .background(Color.white)
                                    .cornerRadius(8) // Smaller corner radius
                                    .shadow(radius: 3) // Smaller shadow radius
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // Add share action here
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title3) // Smaller font size
                                    .foregroundColor(.black) // You can change this color based on your design
                                    .padding(9) // Smaller padding
                                    .background(Color.white)
                                    .cornerRadius(8) // Smaller corner radius
                                    .shadow(radius: 3) // Smaller shadow radius
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 45)
                        
                        
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                HStack {
                                    Image(systemName: "megaphone.fill")
                                        .foregroundColor(.black)
                                    Text("目前已经找到了5个人，还差1个人一起同行。有没有顺路的朋友愿意加入呢？如果有兴趣的，欢迎随时联系我，感谢！")
                                        .font(.subheadline)
                                        .lineLimit(nil) // 允许文本自动折行
                                        .multilineTextAlignment(.leading) // 设置文本左对齐（可以根据需求调整为 .center 或 .trailing）
                                }
                                .padding(8)
                                .background(Color.gray.opacity(0.5))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .padding(16)
                            }
                        }
                    }
                    VStack{
                        HStack {
                            Spacer() // Center the dots
                            ForEach(0..<recipe.imageNames.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentImageIndex ? Color.black : Color.gray)
                                    .frame(width: 8, height: 8)
                            }
                            Spacer() // Center the dots
                        }
                        .padding(.bottom, 8)
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    // 头像图片
                                    Image("sample2") // 替换为你自己的头像图片
                                        .resizable()
                                        .frame(width: 30, height: 30) // 设置头像大小
                                        .clipShape(Circle()) // 将头像裁剪为圆形
                                        .padding(.trailing, 1) // 在右侧增加间距，让它和头像分开一些
                                    // 昵称
                                    Text("劉子源")
                                        .foregroundColor(.blue) // 设置字体颜色为蓝色
                                        .font(.subheadline) // 设置昵称的字体样式
                                    Spacer()
                                    HStack {
                                        Image(systemName: "clock.arrow.circlepath")
                                        Text("3 days")
                                        
                                            .lineLimit(1) // Avoid text wrapping
                                        
                                    }
                                }
                                VStack(alignment: .leading) {
                                    // 标题
                                    Text("我今天去入管局办事，有没有顺路的啊有没有顺路的啊")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    // 标签
                                    HStack {
                                        // 第一个标签：娱乐
                                        HStack {
                                            Text("娱乐")
                                                .font(.caption) // 设置字体更小
                                        }
                                        .padding(4)
                                        .background(Color.gray.opacity(0.2)) // 设置背景为灰色
                                        .cornerRadius(6) // 设置圆角
                                        .foregroundColor(.black) // 字体颜色

                                        // 间距
                                        Spacer().frame(width: 8)

                                        // 第二个标签：兼职
                                        HStack {
                                            Text("兼职")
                                                .font(.caption) // 设置字体更小
                                        }
                                        .padding(4)
                                        .background(Color.gray.opacity(0.2)) // 设置背景为灰色
                                        .cornerRadius(6) // 设置圆角
                                        .foregroundColor(.black) // 字体颜色
                                    }
                                }
                                
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundColor(.gray)
                                    Text("東京,葛飾区,立石４丁目 ")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    Spacer() // Push the button to the right
                                    
                                    Button(action: {
                                        // Add favorite action here
                                    }) {
                                        Image(systemName: "star.fill")
                                            .font(.title3) // Adjust size as needed
                                            .foregroundColor(.yellow)
                                            .padding(6) // Adjust padding as needed
                                            .background(Color.white)
                                            .cornerRadius(6) // Adjust corner radius as needed
                                            .shadow(radius: 4) // Adjust shadow as needed
                                    }
                                }
                            }
                            
                            Spacer()
                            
                           
                        }
                        .padding(.horizontal)
                        Divider()
                            .padding(.horizontal)
                        
                        // Amenities Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Details")
                                .font(.headline)
                                .padding(.horizontal) // Ensure this padding matches with the content section
                            
                            HStack(spacing: 10) {
                                // Wi-Fi Amenity
                                HStack {
                                    Image(systemName: "calendar")
                                    Text("2024-10-01")
                                        .lineLimit(1) // Avoid text wrapping
                                }
                                .padding(8)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(10)
                                .frame(minWidth: 80) // Ensure enough width to avoid wrapping
                                
                                // Air Conditioning Amenity
                                HStack {
                                    Image(systemName: "person.2.fill")
                                    Text("75＋")
                                        .lineLimit(1) // Avoid text wrapping
                                }
                                .padding(8)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(10)
                                .frame(minWidth: 80) // Ensure enough width to avoid wrapping
                            }
                            .padding(.horizontal) // Apply the same padding to ensure alignment with other sections
                            
                            // Other content
                            Text("Content")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Text("今天早上我有个计划，就是去入管局办理一些手续。最近一直忙着工作，所以这件事拖了好久。想着今天正好有空，赶紧去处理一下。听说入管局那边今天可能人会比较多，所以我打算早点出发，不知道有没有人顺路一起的？如果有一起去的可以顺便聊聊，也能互相帮个忙。毕竟在入管局排队的时候有个熟人聊聊天，时间也会过得快一点。其实最近的事情不少，很多事情都堆在一起处理，真希望能赶快把这些杂事都搞定。你们有没有类似的情况？处理这些手续真的是既耗时间又耗精力。")
                                .font(.body)
                                .padding(.horizontal)
                            Spacer()
                        }
                    }
                }
            }
            // 固定按钮在视图的底部，不随滚动变化
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    Button(action: {
                        // 动作在这里可以设置
                    }) {
                        Text("Join")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(Color.black)
                            )
                            .shadow(radius: 10)
                            .opacity(0.8)
                    }
                    // 使用缩放效果来创建自动变化的视觉效果
                    .scaleEffect(isPressed ? 1.2 : 1.0) // 持续缩放
                    .position(x: geometry.size.width / 2, y: geometry.size.height - 50) // 固定按钮在底部上方
                }
                .onReceive(timer) { _ in
                    // 每隔 1 秒自动触发缩放变化
                    withAnimation(.easeInOut(duration: 1)) {
                        isPressed.toggle()
                    }
                }
            }
        }
                        .edgesIgnoringSafeArea(.top) // 让整个 ScrollView 忽略顶部安全区域
                        .navigationBarHidden(true)
                        .onAppear {
                            tabBarManager.isViewTabBarHidden = true // Hide TabBar when HomeView appears
                        }
                        .onDisappear {
                            tabBarManager.isViewTabBarHidden = false // Show TabBar when HomeView disappears
                        }
      }
}

// Mock Data for Preview
struct RecommendedRecipe: Identifiable, Hashable {
    let id = UUID() // Unique identifier for each recipe
    let imageName: String
    let title: String
    let imageNames: [String] // List of image names for horizontal scrolling
}

// Preview with Fake Data
struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeDetailView(
            recipe: RecommendedRecipe(
                imageName: "reco_1",
                title: "折扣 JJ 京东京",
                imageNames: ["sample1", "reco_1", "reco_1", "reco_1"] // 4 example images
            )
        )
        .environmentObject(TabBarManager()) // Injecting TabBarManager instance
    }
}



