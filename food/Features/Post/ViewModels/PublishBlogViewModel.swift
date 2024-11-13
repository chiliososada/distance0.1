////
////  PublishBlogViewModel.swift
////  food
////
////  Created by toyousoft on 2024/11/13.
////
//
//import SwiftUI
//import Combine
//
//class PublishBlogViewModel: ObservableObject {
//    @Published var selectedDuration: String = "1 Month"
//    @Published var chatRoomEnabled: Bool = false
//    @Published var announcement: String = ""
//    @Published var showingDurationInfo = false
//    @Published var showingChatInfo = false
//    
//    // 从 PostInputView 传递过来的数据
//    var postTitle: String = ""
//    var postContent: String = ""
//    var postLocation: String = ""
//    var postTags: [String] = []
//    var postImages: [UIImage] = []
//    
//    // 发布状态
//    @Published var isPublishing: Bool = false
//    @Published var showPublishSuccess: Bool = false
//    @Published var showPublishError: Bool = false
//    
//    // 草稿相关
//    struct BlogDraft: Codable {
//        let postDraft: BlogDraft
//        let selectedDuration: String
//        let chatRoomEnabled: Bool
//        let announcement: String
//    }
//    
//    // 保存完整的草稿（包括帖子内容和发布设置）
//    func saveDraft() {
//        // 首先保存图片
//        let imageIdentifiers = postImages.compactMap { image in
//            DraftImageManager.shared.saveImage(image)
//        }
//        
//        // 创建 PostDraft
//        let BlogDraft = BlogDraft(
//            title: postTitle,
//            content: postContent,
//            location: postLocation,
//            tags: postTags,
//            imageNames: imageIdentifiers
//        )
//        
//        // 创建包含发布设置的完整草稿
//        let blogDraft = BlogDraft(
//            postDraft: postDraft,
//            selectedDuration: selectedDuration,
//            chatRoomEnabled: chatRoomEnabled,
//            announcement: announcement
//        )
//        
//        // 保存到 UserDefaults
//        if let encoded = try? JSONEncoder().encode(blogDraft) {
//            UserDefaults.standard.set(encoded, forKey: "blog_draft")
//        }
//    }
//    
//    // 加载草稿
//    func loadDraft() {
//        guard let data = UserDefaults.standard.data(forKey: "blog_draft"),
//              let blogDraft = try? JSONDecoder().decode(BlogDraft.self, from: data) else {
//            return
//        }
//        
//        // 设置发布设置
//        selectedDuration = blogDraft.selectedDuration
//        chatRoomEnabled = blogDraft.chatRoomEnabled
//        announcement = blogDraft.announcement
//        
//        // 设置帖子内容
//        postTitle = blogDraft.postDraft.title
//        postContent = blogDraft.postDraft.content
//        postLocation = blogDraft.postDraft.location
//        postTags = blogDraft.postDraft.tags
//        
//        // 加载图片
//        postImages = blogDraft.postDraft.imageNames.compactMap { identifier in
//            DraftImageManager.shared.loadImage(identifier: identifier)
//        }
//    }
//    
//    // 清除草稿
//    func clearDraft() {
//        UserDefaults.standard.removeObject(forKey: "blog_draft")
//        DraftImageManager.shared.clearAllDraftImages()
//        
//        // 重置所有状态
//        selectedDuration = "1 Month"
//        chatRoomEnabled = false
//        announcement = ""
//        postTitle = ""
//        postContent = ""
//        postLocation = ""
//        postTags = []
//        postImages = []
//    }
//    
//    // 检查是否有草稿
//    func hasDraft() -> Bool {
//        return UserDefaults.standard.data(forKey: "blog_draft") != nil
//    }
//    
//    // 发布博客
//    func publishBlog(completion: @escaping (Bool) -> Void) {
//        isPublishing = true
//        
//        // 这里添加实际的发布逻辑
//        // 模拟网络请求
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            self.isPublishing = false
//            self.showPublishSuccess = true
//            completion(true)
//            
//            // 发布成功后清除草稿
//            self.clearDraft()
//        }
//    }
//}
