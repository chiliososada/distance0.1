//
//  APIError.swift
//  food
//
//  Created by toyousoft on 2025/02/18.
//

// APIError.swift
import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
    case unauthorized
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .invalidResponse:
            return "无效的响应"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .decodingError(let error):
            return "数据解析错误: \(error.localizedDescription)"
        case .serverError(let code):
            return "服务器错误: \(code)"
        case .unauthorized:
            return "未授权访问"
        case .noData:
            return "没有数据"
        }
    }
}
