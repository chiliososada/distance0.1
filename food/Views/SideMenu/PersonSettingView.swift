import SwiftUI

struct PersonSettingsView: View {
    @State private var isHiddenPhoneEnabled = false // 控制开关
    @State private var cacheSize = "1.7M" // 假定缓存大小
    @State private var appVersion = "1.2.8(171)" // 假定版本号
    @Environment(\.presentationMode) var presentationMode // 用于后退功能

    var body: some View {
        VStack {
            List {
                // 第二部分：修改密码、清除缓存、检查更新
                Section {
                    // 修改密码按钮，使用 NavigationLink 处理跳转
                    NavigationLink(destination: PasswordChangeView()) {
                        HStack {
                            Text("修改密码")
                                .foregroundColor(.primary)
                          
                        }
                        .padding(.vertical, 10)
                    }
                    
                    // 清除缓存
                    HStack {
                        Text("清除缓存")
                        Spacer()
                        Text(cacheSize) // 显示缓存大小
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 10)
                    
                    // 检测更新
                    HStack {
                        Text("检测更新")
                        Spacer()
                        Text(appVersion) // 显示版本号
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 10)
                }
                
                // 第三部分：账户注销和退出
                Section {
                    // 注销账户
                    Button(action: {
                        // 注销账户的逻辑
                    }) {
                        Text("注销账户")
                            .foregroundColor(.red)
                    }
                    .padding(.vertical, 10)
                    
                    // 退出
                    Button(action: {
                        // 处理“退出”的逻辑
                    }) {
                        HStack {
                            Text("退出")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
            .listStyle(.plain) // 使用简洁的列表样式
            .padding(.horizontal, 20) // 保证内容与边缘的距离
        }
        .navigationTitle("个人设置")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
            }
        )
    }
}



struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PersonSettingsView()
        }
    }
}
