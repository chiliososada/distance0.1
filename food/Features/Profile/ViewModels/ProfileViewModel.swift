//
//  ProfileViewModel.swift
//  food
//
//  Created by toyousoft on 2024/11/04.
//

import SwiftUI
import MapKit

// MARK: - ViewModel
final class ProfileViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var offset: CGFloat = 0
    @Published var mapImage: UIImage?
    @Published var mapPreviewImage: UIImage?
    @Published var isLoadingMap = true
    
    private let coordinate = CLLocationCoordinate2D(latitude: 35.7433, longitude: 139.8476)
    
    var userProfile: UserProfile
    
    init() {
        // 创建一个示例用户配置
        self.userProfile = UserProfile(
            id: "user123",
            userName: "liu ziyuan",
            email: "example@email.com",
            phoneNumber: nil,
            location: "東京都 葛飾区 立石",
            bio: "我是一个专注于前端开发的程序员",
            avatarUrl: "sample1",
            settings: UserProfile.Settings(
                nickname: "东京 it 小白",
                bio: "美妙的生活由此开始~",
                idNumber: "178385",
                gender: .male,
                birthDate: Date(),
                notificationsEnabled: true,
                privacySettings: UserProfile.Settings.PrivacySettings(
                    isProfilePublic: true,
                    showLocation: true,
                    showOnlineStatus: true
                )
            ),
            stats: UserProfile.UserStats(
                participantsCount: 1200,
                viewedTopicsCount: 1500000,
                postsCount: 42,
                followersCount: 358,
                followingCount: 285
            )
        )
        
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
    
    func handleEdit(_ item: LocationPost) {
        print("Editing item: \(item.id)")
    }
    
    func handleDelete(_ item: LocationPost) {
        print("Deleting item: \(item.id)")
    }
    
    var publishedContent: [LocationPost] = [
        LocationPost(
            title: "有一起去吃中华料理的吗？",
            content: "This is a sample review text. It discusses the product or service in detail and gives insights about its pros and cons.",
            authorName: "John Doe",
            locationName: "東京都 葛飾区 立石",
            latitude: 35.7433,
            longitude: 139.8476,
            imageNames: ["sample1"],
            avatarImage: "sample1",
            tags: ["活动", "社交", "健身"],
            participantsCount: 99,
            postedTime: "3 days",
            remainingDays: "7 days",
            publishDate: "2024-10-03",
            joinedCount: "75+",
            cachedDistance: 300
        )
    ]
    
    var savedContent: [LocationPost] = [
        LocationPost(
            title: "有一起去吃中华料理的吗？",
            content: "This is a sample review text. It discusses the product or service in detail and gives insights about its pros and cons.",
            authorName: "John Doe",
            locationName: "東京都 葛飾区 立石",
            latitude: 35.7433,
            longitude: 139.8476,
            imageNames: ["sample1"],
            avatarImage: "sample1",
            tags: ["活动", "社交", "健身"],
            participantsCount: 99,
            postedTime: "1 Day",
            remainingDays: "7 days",
            publishDate: "2024-10-03",
            joinedCount: "75+",
            cachedDistance: 300
        )
    ]
}
