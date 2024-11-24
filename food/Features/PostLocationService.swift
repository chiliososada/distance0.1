//
//  LocationService.swift
//  food
//
//  Created by toyousoft on 2024/11/09.
//

import Foundation
import MapKit
import SwiftUI

// MARK: - API Errors
enum LocationError: LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "无效的URL"
        case .invalidResponse: return "无效的响应"
        case .networkError(let error): return "网络错误: \(error.localizedDescription)"
        case .decodingError(let error): return "解码错误: \(error.localizedDescription)"
        case .serverError(let code): return "服务器错误: \(code)"
        }
    }
}

// MARK: - Location Service
@MainActor
class PostLocationService: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var posts: [LocationPost] = []
    @Published private(set) var filteredPosts: [LocationPost] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    // MARK: - Private Properties
    private let baseURL: String
    private let session: URLSession
    private var activeRequests: [String: Task<[LocationPost], Error>] = [:]
    private let isTestMode: Bool
    
    // MARK: - Mock Data
    private let mockData: [LocationPost] = [
        LocationPost(
            title: "浅草寺夜景摄影",
            content: "想找几位摄影爱好者，一起去浅草寺拍摄夜景。最近天气不错，适合夜景拍摄。欢迎各位摄影爱好者参加！",
            authorName: "摄影达人",
            locationName: "東京都台東区浅草2丁目",
            latitude: 35.7147,
            longitude: 139.7966,
            imageNames: ["4_5", "sample1", "sample3"],
            avatarImage: "sample2",
            tags: ["摄影", "夜景", "文化"],
            participantsCount: 45,
            postedTime: "5小时前",
            remainingDays: "2天",
            publishDate: "2024-11-20",
            joinedCount: "40+",
            isSponsored: true
        ),
        
        LocationPost(
            title: "秋叶原电玩交流会",
            content: "在秋叶原组织一个游戏交流会，主要讨论最新的主机游戏。带上你的游戏机来一起玩吧！",
            authorName: "游戏迷",
            locationName: "東京都千代田区外神田",
            latitude: 35.6989,
            longitude: 139.7714,
            imageNames: ["sample1", "sample3", "sample4", "4_5"],
            avatarImage: "sample1",
            tags: ["游戏", "交流", "动漫"],
            participantsCount: 88,
            postedTime: "2小时前",
            remainingDays: "5天",
            publishDate: "2024-11-21",
            joinedCount: "80+"
        ),
        
        LocationPost(
            title: "新宿公园晨练",
            content: "每天早上6点在新宿中央公园晨练，欢迎附近的朋友一起来！适合各个年龄段的人参加。",
            authorName: "健身爱好者",
            locationName: "東京都新宿区西新宿",
            latitude: 35.6851,
            longitude: 139.6918,
            imageNames: ["sample3", "4_5"],
            avatarImage: "sample3",
            tags: ["运动", "健康", "社交"],
            participantsCount: 125,
            postedTime: "1天前",
            remainingDays: "长期",
            publishDate: "2024-11-15",
            joinedCount: "100+",
            cachedDistance: 500
        ),
        
        LocationPost(
            title: "寿司制作教室",
            content: "专业寿司师傅教学，从基础的醋饭制作到卷寿司技巧，全程手把手教学。提供所有必需材料。",
            authorName: "寿司达人",
            locationName: "東京都目黒区",
            latitude: 35.6331,
            longitude: 139.7089,
            imageNames: ["sample1", "4_5", "sample3", "sample4"],
            avatarImage: "sample4",
            tags: ["美食", "教学", "日本文化"],
            participantsCount: 20,
            postedTime: "6小时前",
            remainingDays: "1周",
            publishDate: "2024-11-18",
            joinedCount: "15+"
        ),
        
        LocationPost(
            title: "银座购物指南",
            content: "作为常年在银座工作的导购，想和大家分享一些购物省钱技巧和隐藏优惠信息。",
            authorName: "购物达人",
            locationName: "東京都中央区銀座",
            latitude: 35.6712,
            longitude: 139.7645,
            imageNames: ["4_5", "sample1"],
            avatarImage: "sample2",
            tags: ["购物", "攻略", "省钱"],
            participantsCount: 230,
            postedTime: "12小时前",
            remainingDays: "3天",
            publishDate: "2024-11-19",
            joinedCount: "200+",
            isSponsored: true
        ),
        
        LocationPost(
            title: "皇居跑步团",
            content: "每周末早上8点在皇居外苑集合，一起跑步。适合各个水平的跑者，我们会分组进行。",
            authorName: "跑步爱好者",
            locationName: "東京都千代田区",
            latitude: 35.6852,
            longitude: 139.7528,
            imageNames: ["sample3", "sample4", "4_5"],
            avatarImage: "sample1",
            tags: ["运动", "跑步", "健康"],
            participantsCount: 168,
            postedTime: "2天前",
            remainingDays: "长期",
            publishDate: "2024-11-16",
            joinedCount: "150+",
            cachedDistance: 800
        ),
        
        LocationPost(
            title: "和服体验之旅",
            content: "在浅草地区提供和服租赁和穿着指导，包括专业摄影服务。想体验日本传统文化的朋友不要错过！",
            authorName: "文化体验家",
            locationName: "東京都台東区浅草",
            latitude: 35.7148,
            longitude: 139.7967,
            imageNames: ["sample1", "sample3", "4_5", "sample4"],
            avatarImage: "sample3",
            tags: ["文化", "体验", "摄影"],
            participantsCount: 75,
            postedTime: "1天前",
            remainingDays: "4天",
            publishDate: "2024-11-17",
            joinedCount: "70+"
        ),
        
        LocationPost(
            title: "代代木公园野餐会",
            content: "这周末在代代木公园举办国际野餐会，每个人带一道自己国家的特色美食，一起交流分享。",
            authorName: "美食社交家",
            locationName: "東京都渋谷区代々木",
            latitude: 35.6712,
            longitude: 139.6944,
            imageNames: ["4_5", "sample1", "sample3"],
            avatarImage: "sample4",
            tags: ["美食", "社交", "野餐"],
            participantsCount: 95,
            postedTime: "3天前",
            remainingDays: "2天",
            publishDate: "2024-11-22",
            joinedCount: "90+"
        ),
        
        LocationPost(
            title: "神宫外苑红叶观赏",
            content: "组织赏枫活动，会请专业导游讲解各种枫树品种和摄影技巧。喜欢秋日风景的朋友们一起来吧！",
            authorName: "自然爱好者",
            locationName: "東京都新宿区信濃町",
            latitude: 35.6792,
            longitude: 139.7177,
            imageNames: ["sample1", "4_5"],
            avatarImage: "sample2",
            tags: ["观光", "摄影", "自然"],
            participantsCount: 145,
            postedTime: "4小时前",
            remainingDays: "1天",
            publishDate: "2024-11-23",
            joinedCount: "140+"
        ),
        
        LocationPost(
            title: "六本木艺术展导览",
            content: "正在举办的现代艺术展需要几位翻译志愿者，可以免费参观展览，还能结识来自世界各地的艺术家。",
            authorName: "艺术馆长",
            locationName: "東京都港区六本木",
            latitude: 35.6625,
            longitude: 139.7316,
            imageNames: ["sample3", "sample4", "4_5", "sample1"],
            avatarImage: "sample1",
            tags: ["艺术", "志愿者", "展览"],
            participantsCount: 50,
            postedTime: "8小时前",
            remainingDays: "6天",
            publishDate: "2024-11-24",
            joinedCount: "45+",
            isSponsored: true
        )
    ]
    
    // MARK: - Singleton
    static let shared = PostLocationService()
    
    // MARK: - Initialization
    private init(baseURL: String = "https://your-api-endpoint.com",
                session: URLSession = .shared,
                isTestMode: Bool = true) {
        self.baseURL = baseURL
        self.session = session
        self.isTestMode = isTestMode
        if isTestMode {
            self.posts = mockData
            self.filteredPosts = mockData
        }
    }
    
    // MARK: - Public Methods
    func fetchPosts(in region: MKCoordinateRegion? = nil, searchText: String = "") async throws {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            // 1. 获取数据
            var newPosts: [LocationPost]
            if isTestMode {
                newPosts = mockData
            } else {
                newPosts = try await fetchFromAPI(region: region)
            }
            
            // 2. 应用过滤
            if let region = region {
                newPosts = newPosts.filter { isPost($0, inRegion: region) }
            }
            
            if !searchText.isEmpty {
                newPosts = newPosts.filter { matchesSearchCriteria($0, searchText: searchText) }
            }
            
            // 3. 更新状态
            posts = newPosts
            filteredPosts = newPosts
            
        } catch {
            self.error = error
            throw error
        }
    }
    
    // MARK: - Private Methods
    private func fetchFromAPI(region: MKCoordinateRegion?) async throws -> [LocationPost] {
        guard let region = region else { return [] }
        
        let regionKey = generateRegionKey(for: region)
        activeRequests[regionKey]?.cancel()
        
        let task = Task<[LocationPost], Error> {
            let parameters = [
                "latitude": String(region.center.latitude),
                "longitude": String(region.center.longitude),
                "latitudeDelta": String(region.span.latitudeDelta),
                "longitudeDelta": String(region.span.longitudeDelta)
            ]
            
            var components = URLComponents(string: baseURL + "/api/locations")
            components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
            
            guard let url = components?.url else {
                throw LocationError.invalidURL
            }
            
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw LocationError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw LocationError.serverError(httpResponse.statusCode)
            }
            
            return try JSONDecoder().decode([LocationPost].self, from: data)
        }
        
        activeRequests[regionKey] = task
        
        do {
            let result = try await task.value
            activeRequests[regionKey] = nil
            return result
        } catch {
            activeRequests[regionKey] = nil
            throw error
        }
    }
    
    private func isPost(_ post: LocationPost, inRegion region: MKCoordinateRegion) -> Bool {
        let coordinate = post.coordinate
        let latDelta = region.span.latitudeDelta / 2.0
        let lonDelta = region.span.longitudeDelta / 2.0
        
        return coordinate.latitude >= region.center.latitude - latDelta &&
               coordinate.latitude <= region.center.latitude + latDelta &&
               coordinate.longitude >= region.center.longitude - lonDelta &&
               coordinate.longitude <= region.center.longitude + lonDelta
    }
    
    private func matchesSearchCriteria(_ post: LocationPost, searchText: String) -> Bool {
        post.title?.localizedCaseInsensitiveContains(searchText) == true ||
        post.content.localizedCaseInsensitiveContains(searchText) ||
        post.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    private func generateRegionKey(for region: MKCoordinateRegion) -> String {
        let lat = String(format: "%.4f", region.center.latitude)
        let lon = String(format: "%.4f", region.center.longitude)
        return "\(lat):\(lon)"
    }
}
