import SwiftUI

struct PublishBlogView: View {
    @ObservedObject var viewModel: PostInputViewModel
    @Environment(\.dismiss) private var dismiss
    
//    // 从上一个页面传递数据
//    init(postTitle: String, postContent: String, postLocation: String, postTags: [String], postImages: [UIImage]) {
//        let vm = PublishBlogViewModel()
//        vm.postTitle = postTitle
//        vm.postContent = postContent
//        vm.postLocation = postLocation
//        vm.postTags = postTags
//        vm.postImages = postImages
//        _viewModel = StateObject(wrappedValue: vm)
//    }
    
    private let spacing: CGFloat = 20
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: spacing) {
                // 持续时长部分
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 4) {
                                Text("持续时长")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        viewModel.showingDurationInfo.toggle()
                                    }
                                }) {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                }
                            }
                            
                            if viewModel.showingDurationInfo {
                                Text("发布话题的持续时间，在聊天室中可以延长话题时间")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 2)
                                    .transition(.opacity)
                            }
                        }
                    }
                    
                    HStack(spacing: 8) {
                        ForEach(["1 Month", "1 Week", "1 Day"], id: \.self) { duration in
                            DurationButton(title: duration,
                                         icon: "clock",
                                         selected: $viewModel.selectedDuration)
                        }
                    }
                }
                
                Divider()
                
                // 聊天室设置部分
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 4) {
                                Text("聊天室设置")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        viewModel.showingChatInfo.toggle()
                                    }
                                }) {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                }
                            }
                            
                            if viewModel.showingChatInfo {
                                Text("开启后话题将创建专属聊天室，参与者可以实时讨论")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 2)
                                    .transition(.opacity)
                            }
                        }
                    }
                    
                    PostToggleButton(isEnabled: $viewModel.chatRoomEnabled,
                                   title: "开启群聊",
                                   selectedTitle: "开启群聊")
                }
                
                // 只在开启群聊时显示群公告部分
                if viewModel.chatRoomEnabled {
                    Divider()
                        .transition(.opacity)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("群公告")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                        
                        TextEditor(text: $viewModel.announcement)
                            .frame(height: 180)
                            .font(.system(size: 15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray5), lineWidth: 1)
                            )
                    }
                  
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .animation(.easeInOut(duration: 0.3), value: viewModel.chatRoomEnabled)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            leading: BackPostButton(),
            trailing: PublishConfirmButton(viewModel: viewModel)
        )
        .background(Color(.systemBackground))
        .alert("发布成功", isPresented: $viewModel.showPublishSuccess) {
            Button("确定") {
                dismiss()
            }
        }
    }
}

// 返回按钮
struct BackPostButton: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button(action: {
            dismiss()
        }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.black)
        }
    }
}

// 发布确认按钮
struct PublishConfirmButton: View {
    @ObservedObject var viewModel: PostInputViewModel
    
    var body: some View {
        Button(action: {
            viewModel.publishBlog { success in
                // 处理发布结果
            }
        }) {
            if viewModel.isPublishing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .tint(.white)
            } else {
                Text("发布")
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .foregroundColor(.white)
                    .background(Color.black)
                    .cornerRadius(25)
            }
        }
        .disabled(viewModel.isPublishing)
    }
}

// 持续时长按钮
struct DurationButton: View {
    let title: String
    let icon: String
    @Binding var selected: String
    
    var body: some View {
        Button(action: {
            selected = title
        }) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 14))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(
                selected == title ?
                Color.black :
                Color(.systemGray6)
            )
            .foregroundColor(selected == title ? .white : .primary)
            .cornerRadius(8)
            .animation(.easeInOut(duration: 0.2), value: selected)
        }
    }
}

// 开关按钮
struct PostToggleButton: View {
    @Binding var isEnabled: Bool
    let title: String
    let selectedTitle: String
    
    var body: some View {
        Button(action: {
            withAnimation {
                isEnabled.toggle()
            }
        }) {
            HStack {
                Text(isEnabled ? selectedTitle : title)
                    .font(.system(size: 14))
                
                Spacer()
                
                Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isEnabled ? .black : .gray)
                    .font(.system(size: 16))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(8)
        }
        .foregroundColor(.primary)
    }
}

// 预览 Provider
//struct PublishBlogView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            PublishBlogView(
//                postTitle: "测试标题",
//                postContent: "测试内容",
//                postLocation: "测试位置",
//                postTags: ["#测试"],
//                postImages: []
//            )
//        }
//    }
//}
