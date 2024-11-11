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
            title: "东京中央市场",
            content: "这里是东京最大的海鲜市场，每天清晨都有新鲜的金枪鱼拍卖",
            authorName: "美食探险家",
            locationName: "東京都中央区築地5丁目",
            latitude: 35.6654,
            longitude: 139.7707,
            imageNames: ["sample1", "sample1", "sample1"],
            avatarImage: "sample1",
            tags: ["美食", "市场", "海鲜"],
            participantsCount: 156,
            postedTime: "3小时前",
            remainingDays: "长期",
            publishDate: "2024-11-09",
            joinedCount: "150+",
            isSponsored: true
        ),
        LocationPost(
            title: "有一起打球的的吗",
            content: "今天早上我有个计划，就是去入管局办理一些手续。最近一直忙着工作，所以这件事拖了好久。想着今天正好有空，赶紧去处理一下。",
            authorName: "劉子源",
            locationName: "東京都 葛飾区 立石",
            latitude: 35.681236,
            longitude: 139.767125,
            imageNames: ["4_5", "sample1", "sample3", "sample4"],
            avatarImage: "sample2",
            tags: ["娱乐", "运动", "篮球"],
            participantsCount: 99,
            postedTime: "10 mins",
            remainingDays: "3 days",
            publishDate: "2024-10-01",
            joinedCount: "75＋",
            cachedDistance: 300
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
