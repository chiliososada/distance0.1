//
//  ProfileViewModel.swift
//  food
//
//  Created by toyousoft on 2024/11/04.
//

import  SwiftUI
import MapKit

// MARK: - ViewModel
final class ProfileViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var offset: CGFloat = 0
    @Published var mapImage: UIImage?
    @Published var mapPreviewImage: UIImage?
    @Published var isLoadingMap = true
    
    private let coordinate = CLLocationCoordinate2D(latitude: 35.7433, longitude: 139.8476) // 您的当前位置坐标
    let userStats = UserStats(participantsCount: "1K+", viewedTopicsCount: "1M+")
    let userProfile = UserProfile(
            userId: "user123",
            userName: "liu ziyuan",
            location: "東京都 葛飾区 立石",
            bio: "我是一个专注于前端开发的程序员",
            avatarUrl: "sample1"
        )
        
        init() {
            generateMapSnapshots()
        }
    
    private func generateMapSnapshots() {
         // 生成全屏背景地图
         let backgroundOptions = MKMapSnapshotter.Options()
         backgroundOptions.region = MKCoordinateRegion(
             center: coordinate,
             span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
         )
         backgroundOptions.size = CGSize(
             width: UIScreen.main.bounds.width,
             height: UIScreen.main.bounds.height
         )
         backgroundOptions.mapType = .standard
         
         let backgroundSnapshotter = MKMapSnapshotter(options: backgroundOptions)
         backgroundSnapshotter.start { [weak self] snapshot, error in
             DispatchQueue.main.async {
                 if let snapshot = snapshot {
                     self?.mapImage = snapshot.image
                 }
                 self?.isLoadingMap = false
             }
         }
         
         // 生成顶部预览地图
         let previewOptions = MKMapSnapshotter.Options()
         previewOptions.region = MKCoordinateRegion(
             center: coordinate,
             span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
         )
         previewOptions.size = CGSize(width: UIScreen.main.bounds.width - 32, height: 200)
         previewOptions.mapType = .standard
         
         let previewSnapshotter = MKMapSnapshotter(options: previewOptions)
         previewSnapshotter.start { [weak self] snapshot, error in
             DispatchQueue.main.async {
                 if let snapshot = snapshot {
                     self?.mapPreviewImage = snapshot.image
                 }
             }
         }
     }
    
    func handleEdit(_ item: ReviewItem) {
        print("Editing item: \(item.id)")
    }
    
    func handleDelete(_ item: ReviewItem) {
        print("Deleting item: \(item.id)")
    }
    
    var publishedContent: [ReviewItem] = [
        ReviewItem(
            name: "John Doe",
            date: "2024-10-03",
            location: "東京都 葛飾区 立石",
            review: "This is a sample review text. It discusses the product or service in detail and gives insights about its pros and cons.",
            participants: 99,
            tags: ["活动", "社交", "健身"],
            timeElapsed: "3 days",
            distance: "300m",
            title: "有一起去吃中华料理的吗？",
            showAvatar: true,
            avatarImage: "sample1"
        )
    ]
    
    var savedContent: [ReviewItem] = [
        ReviewItem(
            name: "John Doe",
            date: "2024-10-03",
            location: "東京都 葛飾区 立石",
            review: "This is a sample review text. It discusses the product or service in detail and gives insights about its pros and cons.",
            participants: 99,
            tags: ["活动", "社交", "健身"],
            timeElapsed: "1 Day",
            distance: "300m",
            title: "有一起去吃中华料理的吗？",
            showAvatar: true,
            avatarImage: "sample1"
        )
    ]
}


