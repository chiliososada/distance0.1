//
//  RecipeDetailView.swift
//  food
//
//  Created by toyousoft on 2024/10/30.
//

import SwiftUI


// MARK: - RecipeDetailView Optimizations
struct PostDetailView: View {
    let post: LocationPost
    @State private var currentImageIndex = 0
    @State private var isPressed = false
    @EnvironmentObject var navigationManager: AppNavigationManager

       init(post: LocationPost) {
           print("PostDetailView")
           self.post = post
       }
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    ImageCarouselContent(
                        images: post.imageNames,
                        currentIndex: $currentImageIndex
                    )
                    
                    DetailContent(post: post, currentImageIndex: $currentImageIndex)
                }
            }
            
            FloatingJoinButton(
                isPressed: $isPressed,
                action: handleJoinChat
            )
        }
        .navigationBarTitle(post.formattedDistance, displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { navigationManager.goBack() }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.black)
                        .background(Color.white)
                        .cornerRadius(8)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                        .foregroundColor(.black)
                        .background(Color.white)
                        .cornerRadius(8)
                }
            }
        }
    }

    
    private func handleJoinChat() {
           let chatRoom = createChatRoom()
           navigationManager.navigate(to: .chatDetail(chatRoom: chatRoom))
       }
    
    private func createChatRoom() -> ChatRoom {
        print("Creating chat room from post: \(post.title ?? "")")
        
        // 创建当前用户作为成员
        let currentMember = Member(
            id: UUID(),
            name: "Me", // 这里应该使用实际的当前用户名
            avatar: "sample1", // 这里应该使用实际的当前用户头像
            role: .owner
        )
        
        // 创建初始系统消息
        let initialMessage = Message(
            id: UUID(),
            sender: currentMember,
            content: .system("聊天室已创建"),
            timestamp: Date(),
            status: .sent
        )
        
        return ChatRoom(
            name: post.title ?? "",
            type: post.participantsCount > 2 ? .group : .individual,
            avatar: post.thumbnailImage,
            lastMessage: initialMessage,
            members: [currentMember],
            announcement: post.participantsCount > 2 ? Announcement(
                id: UUID(),
                content: "欢迎加入聊天室",
                timestamp: Date(),
                link: nil,
                creator: currentMember
            ) : nil,
            isTopChat: false
        )
    }
}





// MARK: - DetailContent
struct DetailContent: View {
    let post: LocationPost
    @Binding var currentImageIndex: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Page Indicator
            HStack {
                Spacer()
                ForEach(0..<post.imageNames.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentImageIndex ? Color.black : Color.gray)
                        .frame(width: 8, height: 8)
                        .opacity(index == currentImageIndex ? 1 : 0.3)
                }
                Spacer()
            }
            .padding(.vertical, 8)
            
            // Author Info
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Image(post.avatarImage)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                        Text(post.authorName)
                            .foregroundColor(.blue)
                            .font(.subheadline)
                        Spacer()
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                            Text(post.remainingDays)
                                .lineLimit(1)
                        }
                    }
                    
                    // Title
                    Text(post.title ?? "")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Tags
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(post.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(6)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    
                    // Location
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.gray)
                        Text(post.locationName)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: post.isLiked ? "heart.fill" : "heart")
                                .font(.title3)
                                .foregroundColor(post.isLiked ? .red : .gray)
                                .padding(6)
                                .background(Color.white)
                                .cornerRadius(6)
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.horizontal)
            
            // Details Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Details")
                    .font(.headline)
                    .padding(.horizontal)
                
                HStack(spacing: 10) {
                    DetailItem(icon: "calendar", text: post.publishDate)
                    DetailItem(icon: "person.2.fill", text: post.joinedCount)
                }
                .padding(.horizontal)
                
                Text("Content")
                    .font(.headline)
                    .padding(.horizontal)
                
                Text(post.content)
                    .font(.body)
                    .padding(.horizontal)
            }
        }
    }
}

struct DetailItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(text)
                .lineLimit(1)
        }
        .padding(8)
        .background(Color.blue.opacity(0.2))
        .cornerRadius(10)
        .frame(minWidth: 80)
    }
}

// MARK: - FloatingJoinButton
struct FloatingJoinButton: View {
    @Binding var isPressed: Bool
    let action: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                Button(action: action) {
                    Text("进入")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Circle().fill(Color.blue))
                        .opacity(0.8)
                }
                .position(x: geometry.size.width-60, y: geometry.size.height - 80)
            }
        }
    }
}

// MARK: - Preview
struct PostDetailView_Previews: PreviewProvider {
    static var previewPost = LocationPost(
        title: "有一起打球的的吗",
        content: "今天早上我有个计划，就是去入管局办理一些手续。",
        authorName: "劉子源",
        locationName: "東京都 葛飾区 立石",
        latitude: 35.681236,
        longitude: 139.767125,
        imageNames: ["sample1", "reco_2", "reco_3"],
        avatarImage: "sample2",
        tags: ["娱乐", "运动", "篮球"],
        participantsCount: 99,
        postedTime: "10 mins",
        remainingDays: "3 days",
        publishDate: "2024-10-01",
        joinedCount: "75＋"
    )
    
    static var previews: some View {
        NavigationView {
            PostDetailView(post: previewPost)
                .environmentObject(AppNavigationManager.shared)
        }
    }
}
