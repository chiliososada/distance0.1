//
//  SharedDataModels.swift
//  food
//
//  Created by toyousoft on 2024/11/06.
//

// SharedDataModels.swift

//import SwiftUI
//import MapKit
//// MARK: - 共享帖子模型
//struct PostTopic: Identifiable, Hashable {
//    let id: String
//    let title: String
//    let content: String
//    let authorName: String
//    let location: String
//    // 将 coordinate 拆分为单独的经纬度存储
//    let latitude: Double
//    let longitude: Double
//    let tags: [String]
//    let participantsCount: Int
//    let postedTime: String
//    let distance: Int
//    let imageNames: [String]
//    let avatarImage: String
//    let remainingDays: String
//    let publishDate: String
//    let joinedCount: String
//    
//    // 添加计算属性获取坐标
//    var coordinate: CLLocationCoordinate2D {
//        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//    }
//    func hash(into hasher: inout Hasher) {
//           hasher.combine(id)
//           hasher.combine(latitude)
//           hasher.combine(longitude)
//           hasher.combine(title)
//           hasher.combine(authorName)
//       }
//       
//       static func == (lhs: PostTopic, rhs: PostTopic) -> Bool {
//           lhs.id == rhs.id &&
//           lhs.latitude == rhs.latitude &&
//           lhs.longitude == rhs.longitude &&
//           lhs.title == rhs.title &&
//           lhs.authorName == rhs.authorName
//       }
//}

//// MARK: - 共享数据服务
//final class SharedDataService: ObservableObject {
//    static let shared = SharedDataService()
//    
//    @Published private(set) var PostTopics: [PostTopic] = []
//    @Published private(set) var isLoading = false
//    @Published private(set) var error: Error?
//    
//    private init() {
//        loadInitialData()
//    }
//    
//    private func loadInitialData() {
//        // 模拟数据
//        PostTopics = [
//            PostTopic(
//                id: UUID().uuidString,
//                title: "有一起打球的的吗",
//                content: "今天早上我有个计划，就是去入管局办理一些手续。最近一直忙着工作，所以这件事拖了好久。想着今天正好有空，赶紧去处理一下。",
//                authorName: "劉子源",
//                location: "東京都 葛飾区 立石",
//                latitude: 35.681236,
//                longitude: 139.767125,
//                tags: ["娱乐", "运动", "篮球"],
//                participantsCount: 99,
//                postedTime: "10 mins",
//                distance: 300,
//                imageNames: ["sample1", "reco_2", "reco_3"],
//                avatarImage: "sample2",
//                remainingDays: "3 days",
//                publishDate: "2024-10-01",
//                joinedCount: "75＋"
//            ),
//            PostTopic(
//                id: UUID().uuidString,
//                title: "一起去看电影吧",
//                content: "最近上映了一部很不错的电影，有兴趣的朋友一起去看吧！",
//                authorName: "王小明",
//                location: "東京都 新宿区",
//                latitude: 35.689487,
//                longitude: 139.700706,
//                tags: ["娱乐", "电影", "社交"],
//                participantsCount: 56,
//                postedTime: "20 mins",
//                distance: 500,
//                imageNames: ["4_3", "4_5"],
//                avatarImage: "sample2",
//                remainingDays: "2 days",
//                publishDate: "2024-10-02",
//                joinedCount: "45＋"
//            ),
//            // 可以继续添加更多测试数据
//        ]
//    }
//    
//    // 获取特定区域的帖子
//    func fetchPosts(in region: MKCoordinateRegion) async {
//        await MainActor.run { isLoading = true }
//        
//        do {
//            // 模拟网络延迟
//            try await Task.sleep(nanoseconds: 1_000_000_000)
//            
//            // 根据区域筛选帖子
//            let filteredPosts = PostTopics.filter { post in
//                let coordinate = post.coordinate
//                return coordinate.latitude >= region.center.latitude - region.span.latitudeDelta/2 &&
//                       coordinate.latitude <= region.center.latitude + region.span.latitudeDelta/2 &&
//                       coordinate.longitude >= region.center.longitude - region.span.longitudeDelta/2 &&
//                       coordinate.longitude <= region.center.longitude + region.span.longitudeDelta/2
//            }
//            
//            await MainActor.run {
//                PostTopics = filteredPosts
//                isLoading = false
//            }
//        } catch {
//            await MainActor.run {
//                self.error = error
//                isLoading = false
//            }
//        }
//    }
//    
//    // 将 Post 转换为地图标注 Place
//    func convertToPlace(_ PostTopic: PostTopic) -> Place {
//        Place(
//            id: PostTopic.id,
//            name: PostTopic.title,
//            latitude: PostTopic.coordinate.latitude,
//            longitude: PostTopic.coordinate.longitude,
//            sponsored: false
//        )
//    }
//    
//    // 将 Post 转换为列表项 RecommendedRecipe
//    func convertToRecommendedRecipe(_ PostTopic: PostTopic) -> RecommendedRecipe {
//        RecommendedRecipe(
//            imageName: PostTopic.imageNames.first ?? "",
//            title: PostTopic.title,
//            imageNames: PostTopic.imageNames,
//            authorName: PostTopic.authorName,
//            location: PostTopic.location,
//            tags: PostTopic.tags,
//            participantsCount: PostTopic.participantsCount,
//            postedTime: PostTopic.postedTime,
//            distance: PostTopic.distance,
//            isLiked: false,
//            avatarImage: PostTopic.avatarImage,
//            remainingDays: PostTopic.remainingDays,
//            publishDate: PostTopic.publishDate,
//            joinedCount: PostTopic.joinedCount,
//            content: PostTopic.content
//        )
//    }
//}


