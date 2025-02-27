import Foundation
import MapKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum APIEndpoint {
    case updateUserStatus(isActive: Bool)
    case postLocation(LocationPost.Draft)
    case fetchPosts(region: MKCoordinateRegion)
    case checkSession
    
    var headers: [String: String] {
        var headers = ["Content-Type": "application/json"]
        return headers
    }
    
    var method: HTTPMethod {
        switch self {
        case .updateUserStatus, .postLocation:
            return .post
        case .fetchPosts, .checkSession:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .updateUserStatus:
            return "/api/users/status"
        case .postLocation:
            return "/api/posts"
        case .fetchPosts:
            return "/api/posts/nearby"
        case .checkSession:
            return "/api/v1/auth/checksession"
        }
    }
    
    var body: Encodable? {
        switch self {
        case .updateUserStatus(let isActive):
            return ["isActive": isActive]
        case .postLocation(let draft):
            return draft
        case .fetchPosts(let region):
            return [
                "latitude": region.center.latitude,
                "longitude": region.center.longitude,
                "latitudeDelta": region.span.latitudeDelta,
                "longitudeDelta": region.span.longitudeDelta
            ]
        case .checkSession:
            return nil  // GET 请求不需要请求体
        }
    }
}
