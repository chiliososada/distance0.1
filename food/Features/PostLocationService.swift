import Foundation
import MapKit

// MARK: - API Errors
enum APIError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
}

// MARK: - LocationService
actor PostLocationService {
    // MARK: - Properties
    private let baseURL: String
    private let session: URLSession
    private var activeRequests: [String: Task<[LocationPost], Error>] = [:]
    private let isTestMode: Bool
    
    // MARK: - Mock Data
    private let mockData: [String: [LocationPost]] = [
        "tokyo": [
            LocationPost(
                id: UUID().uuidString,
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
                id: UUID().uuidString,
                title: "浅草寺",
                content: "浅草寺是东京最古老的寺庙，每年吸引数百万游客前来参观",
                authorName: "文化达人",
                locationName: "東京都台東区浅草2丁目",
                latitude: 35.7147,
                longitude: 139.7966,
                imageNames: ["sample1", "sample1"],
                avatarImage: "sample1",
                tags: ["文化", "寺庙", "观光"],
                participantsCount: 234,
                postedTime: "1天前",
                remainingDays: "长期",
                publishDate: "2024-11-08",
                joinedCount: "200+",
                isSponsored: false
            )
        ],
        "shibuya": [
            LocationPost(
                id: UUID().uuidString,
                title: "涉谷美食探店",
                content: "发现一家超赞的拉面店，店主是米其林三星大厨",
                authorName: "吃货小王",
                locationName: "東京都渋谷区道玄坂",
                latitude: 35.6585,
                longitude: 139.7017,
                imageNames: ["sample1", "sample1", "sample1", "sample1"],
                avatarImage: "sample1",
                tags: ["美食", "拉面", "米其林"],
                participantsCount: 89,
                postedTime: "5小时前",
                remainingDays: "1周",
                publishDate: "2024-11-09",
                joinedCount: "80+",
                isSponsored: true
            ),
            LocationPost(
                id: UUID().uuidString,
                title: "涉谷购物体验",
                content: "109百货周年庆，超多限定商品和折扣",
                authorName: "购物达人",
                locationName: "東京都渋谷区神南1丁目",
                latitude: 35.6590,
                longitude: 139.7035,
                imageNames: ["sample1", "sample1"],
                avatarImage: "sample1",
                tags: ["购物", "折扣", "时尚"],
                participantsCount: 167,
                postedTime: "2小时前",
                remainingDays: "3天",
                publishDate: "2024-11-09",
                joinedCount: "160+",
                isSponsored: false
            )
        ],
        "shinjuku": [
            LocationPost(
                id: UUID().uuidString,
                title: "新宿御苑赏枫",
                content: "新宿御苑的枫叶正是最佳观赏期，快来打卡",
                authorName: "自然摄影师",
                locationName: "東京都新宿区内藤町11",
                latitude: 35.6851,
                longitude: 139.7100,
                imageNames: ["sample1", "sample1", "sample1"],
                avatarImage: "sample1",
                tags: ["赏枫", "公园", "摄影"],
                participantsCount: 145,
                postedTime: "6小时前",
                remainingDays: "2周",
                publishDate: "2024-11-09",
                joinedCount: "140+",
                isSponsored: true
            ),
            LocationPost(
                id: UUID().uuidString,
                title: "歌舞伎町探险",
                content: "发现一家超棒的深夜食堂，价格实惠料理美味",
                authorName: "夜生活达人",
                locationName: "東京都新宿区歌舞伎町",
                latitude: 35.6956,
                longitude: 139.7034,
                imageNames: ["sample1", "sample2"],
                avatarImage: "sample1",
                tags: ["美食", "夜生活", "深夜食堂"],
                participantsCount: 78,
                postedTime: "1小时前",
                remainingDays: "长期",
                publishDate: "2024-11-09",
                joinedCount: "70+",
                isSponsored: false
            )
        ]
    ]
    
    // MARK: - Initialization
    init(baseURL: String = "https://your-api-endpoint.com",
         session: URLSession = .shared,
         isTestMode: Bool = true) {  // 默认使用测试模式
        self.baseURL = baseURL
        self.session = session
        self.isTestMode = isTestMode
    }
    
    // MARK: - Public Methods
    func fetchLocations(region: MKCoordinateRegion) async throws -> [LocationPost] {
        if isTestMode {
            return await fetchMockLocations(for: region)
        }
        
        // 生成区域的唯一键
        let regionKey = generateRegionKey(for: region)
        
        // 如果已经有相同区域的请求在进行，取消它
        activeRequests[regionKey]?.cancel()
        
        // 创建新的请求任务
        let task = Task<[LocationPost], Error> {
            // 构建API请求参数
            let parameters = [
                "latitude": String(region.center.latitude),
                "longitude": String(region.center.longitude),
                "latitudeDelta": String(region.span.latitudeDelta),
                "longitudeDelta": String(region.span.longitudeDelta)
            ]
            
            // 构建URL
            var components = URLComponents(string: baseURL + "/api/locations")
            components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
            
            guard let url = components?.url else {
                throw APIError.invalidURL
            }
            
            do {
                let (data, response) = try await session.data(from: url)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw APIError.serverError(httpResponse.statusCode)
                }
                
                // 解码响应数据
                let locations = try JSONDecoder().decode([LocationPost].self, from: data)
                return locations
                
            } catch let error as DecodingError {
                throw APIError.decodingError(error)
            } catch {
                throw APIError.networkError(error)
            }
        }
        
        // 存储当前请求
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
    
    // MARK: - Private Methods
    private func generateRegionKey(for region: MKCoordinateRegion) -> String {
        // 将坐标精确到4位小数（约11米精度）
        let lat = String(format: "%.4f", region.center.latitude)
        let lon = String(format: "%.4f", region.center.longitude)
        return "\(lat):\(lon)"
    }
    
    private func fetchMockLocations(for region: MKCoordinateRegion) -> [LocationPost] {
        // 根据区域返回模拟数据
        if region.center.latitude >= 35.6500 && region.center.latitude <= 35.6700
            && region.center.longitude >= 139.7000 && region.center.longitude <= 139.7800 {
            return mockData["tokyo"] ?? []
        } else if region.center.latitude >= 35.6500 && region.center.latitude <= 35.6600
            && region.center.longitude >= 139.7000 && region.center.longitude <= 139.7100 {
            return mockData["shibuya"] ?? []
        } else if region.center.latitude >= 35.6800 && region.center.latitude <= 35.7000
            && region.center.longitude >= 139.7000 && region.center.longitude <= 139.7200 {
            return mockData["shinjuku"] ?? []
        }
        return []
    }
}

// MARK: - API Response Models
struct APIResponse<T: Decodable>: Decodable {
    let data: T
    let status: String
    let message: String?
}
