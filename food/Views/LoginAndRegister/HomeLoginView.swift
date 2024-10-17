import SwiftUI

struct HomeLoginView: View {
    var velocity: CGFloat = 50
    @EnvironmentObject var tabBarManager: TabBarManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                // 上部动画
                VerticalLineAnimationView()
                    .frame(height: 200)
                    .padding(.top, 100)
                
                // 标题
                Text("参加你周围正在发生的新鲜事。")
                    .bold()
                
                // 注册和登录按钮
                HStack(spacing: 20) {
                    NavigationLink(value: "register") {
                        Text("注册")
                            .frame(width: 100, height: 40)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                    
                    NavigationLink(value: "login") {
                        Text("登陆")
                            .frame(width: 100, height: 40)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.bottom, 10)
                
                // 滚动的内容展示，使用 HStack 实现一排横向排列
                Marquee(targetVelocity: 30) {
                    HStack(spacing: 10) {
                        ProfileCardView(name: "liu ziyuan", location: "東京都 葛飾区 立石", message: "一起去唱歌🎤吧！", tags: ["#中古", "#兼职", "#手机"], distance: "300m", participants: "99人", time: "10 mins")
                        ProfileCardView(name: "liu ziyuan", location: "東京都 葛飾区 立石", message: "一起去跳舞💃吧！", tags: ["#中古", "#兼职", "#手机"], distance: "300m", participants: "99人", time: "10 mins")
                    }
                    .padding(.horizontal)
                }
                .mask(
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .padding(.bottom, 80)
            }
            .navigationDestination(for: String.self) { value in
                if value == "register" {
                    RegisterView().environmentObject(tabBarManager)
                } else if value == "login" {
                    LoginInputView(showBackButton: true).environmentObject(tabBarManager) // 初始页进入登录页面需要返回按钮
                }
            }
        }
    }
}

struct ProfileCardView: View {
    var name: String
    var location: String
    var message: String
    var tags: [String]
    var distance: String
    var participants: String
    var time: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 名字和位置
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.caption)
                        .foregroundColor(.black)
                        .bold()
                    
                    HStack {
                        Image(systemName: "location.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundColor(.gray)
                        
                        Text(location)
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                Spacer()
            }
            
            // 内容
            Text(message)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            // 标签
            HStack(spacing: 4) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.blue.opacity(0.2)))
                }
            }
            
            // 参与人数和时间
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.gray)
                    
                    Text(participants)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.gray)
                    
                    Text(time)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("距离我 \(distance)")
                    .font(.caption)
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 15)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.12), radius: 7, x: 0, y: 4)
        .frame(width: 300)  // 设置卡片宽度
    }
}

struct HomeLoginView_Previews: PreviewProvider {
    static var previews: some View {
        HomeLoginView()
            .environmentObject(TabBarManager()) // 确保注入 TabBarManager 环境对象
    }
}
