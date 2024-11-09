//
//  LocationService.swift
//  food
//
//  Created by toyousoft on 2024/11/09.
//

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
actor LocationService {
    // MARK: - Properties
    private let baseURL: String
    private let session: URLSession
    private var activeRequests: [String: Task<[LocationPost], Error>] = [:]
    
    // MARK: - Initialization
    init(baseURL: String = "https://your-api-endpoint.com",
         session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    // MARK: - Public Methods
    func fetchLocations(region: MKCoordinateRegion) async throws -> [LocationPost] {
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
}

// MARK: - API Response Models
// 如果你的API响应有特定的格式，可以在这里定义相应的模型
// 例如：
struct APIResponse<T: Decodable>: Decodable {
    let data: T
    let status: String
    let message: String?
}
