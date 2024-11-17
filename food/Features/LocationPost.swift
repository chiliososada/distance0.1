import SwiftUI
import MapKit

// MARK: - LocationPost
class LocationPost: NSObject, MKAnnotation, Identifiable, Decodable {
    // MARK: - Essential Properties
    let id: String
       private let _title: String
       let content: String
       let authorName: String
       let locationName: String
       let coordinate: CLLocationCoordinate2D
       let imageNames: [String]
       let avatarImage: String
       let tags: [String]
       let participantsCount: Int
       let postedTime: String
       let remainingDays: String
       let publishDate: String
       let joinedCount: String
       let isSponsored: Bool
       let sponsored: Bool
       
       private var _cachedDistance: Double?
       var cachedDistance: Double? {
           get { _cachedDistance }
           set { _cachedDistance = newValue }
       }
       
       var isLiked: Bool
       
       // MARK: - Computed Properties
       var thumbnailImage: String { imageNames.first ?? "" }
       var title: String? { _title }
       var subtitle: String? { locationName }
    // MARK: - Decodable
      private enum CodingKeys: String, CodingKey {
          case id
          case title = "_title"
          case content
          case authorName
          case locationName
          case latitude
          case longitude
          case imageNames
          case avatarImage
          case tags
          case participantsCount
          case postedTime
          case remainingDays
          case publishDate
          case joinedCount
          case isSponsored
          case sponsored
          case isLiked
      }
    required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // 解码基本属性
            id = try container.decode(String.self, forKey: .id)
            _title = try container.decode(String.self, forKey: .title)
            content = try container.decode(String.self, forKey: .content)
            authorName = try container.decode(String.self, forKey: .authorName)
            locationName = try container.decode(String.self, forKey: .locationName)
            
            // 解码坐标
            let latitude = try container.decode(Double.self, forKey: .latitude)
            let longitude = try container.decode(Double.self, forKey: .longitude)
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            // 解码其他属性
            imageNames = try container.decode([String].self, forKey: .imageNames)
            avatarImage = try container.decode(String.self, forKey: .avatarImage)
            tags = try container.decode([String].self, forKey: .tags)
            participantsCount = try container.decode(Int.self, forKey: .participantsCount)
            postedTime = try container.decode(String.self, forKey: .postedTime)
            remainingDays = try container.decode(String.self, forKey: .remainingDays)
            publishDate = try container.decode(String.self, forKey: .publishDate)
            joinedCount = try container.decode(String.self, forKey: .joinedCount)
            isSponsored = try container.decode(Bool.self, forKey: .isSponsored)
            sponsored = try container.decode(Bool.self, forKey: .sponsored)
            isLiked = try container.decode(Bool.self, forKey: .isLiked)
            
            super.init()
        }
    
    var formattedDistance: String {
        guard let distance = _cachedDistance else { return "距离未知" }
        if distance < 1000 {
            return "距离我 \(Int(distance))m"
        } else {
            let kilometers = Double(round(distance / 100) / 10)
            return "距离我 \(kilometers)km"
        }
    }
    
    // MARK: - NSObject Overrides
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(id)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? LocationPost else { return false }
        return self.id == other.id
    }
    
    // MARK: - Initialization
    init(id: String = UUID().uuidString,
         title: String,
         content: String,
         authorName: String,
         locationName: String,
         latitude: Double,
         longitude: Double,
         imageNames: [String],
         avatarImage: String,
         tags: [String],
         participantsCount: Int,
         postedTime: String,
         remainingDays: String,
         publishDate: String,
         joinedCount: String,
         isSponsored: Bool = false,
         
         isLiked: Bool = false,
         cachedDistance: Double? = nil,
         sponsored: Bool = false) {
        
        self.id = id
        self._title = title
        self.content = content
        self.authorName = authorName
        self.locationName = locationName
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.imageNames = imageNames
        self.avatarImage = avatarImage
        self.tags = tags
        self.participantsCount = participantsCount
        self.postedTime = postedTime
        self.remainingDays = remainingDays
        self.publishDate = publishDate
        self.joinedCount = joinedCount
        self.isSponsored = isSponsored
        self.isLiked = isLiked
        self._cachedDistance = cachedDistance
        self.sponsored = sponsored
        
        super.init()
    }
}

// MARK: - Distance Calculation
extension LocationPost {
    func updateDistance(from coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let postLocation = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
        self._cachedDistance = postLocation.distance(from: location)
    }
    
    func isWithinDistance(_ threshold: Double, from coordinate: CLLocationCoordinate2D) -> Bool {
        if _cachedDistance == nil {
            updateDistance(from: coordinate)
        }
        return _cachedDistance ?? .infinity <= threshold
    }
}

extension LocationPost {
    struct Draft: Codable {
        // 内嵌 DraftImage 定义
               struct DraftImage: Codable, Identifiable {
                   let id: String
                   let localIdentifier: String
                   var uploadStatus: UploadStatus
                   var serverUrl: String?
                   let createdAt: Date
                   
                   enum UploadStatus: String, Codable {
                       case draft      // 草稿状态
                       case uploading  // 上传中
                       case uploaded  // 已上传到服务器
                       case failed    // 上传失败
                   }
                   
                   init(id: String = UUID().uuidString,
                        localIdentifier: String,
                        uploadStatus: UploadStatus = .draft,
                        serverUrl: String? = nil,
                        createdAt: Date = Date()) {
                       self.id = id
                       self.localIdentifier = localIdentifier
                       self.uploadStatus = uploadStatus
                       self.serverUrl = serverUrl
                       self.createdAt = createdAt
                   }
               }
        var title: String = ""
        var content: String = ""
        var location: LocationInfo = LocationInfo()
        var draftImages: [DraftImage] = []  // 临时草稿图片
        var imageUrls: [String] = []        // 已上传的图片URL
        var tags: [String] = []
        var selectedDuration: String = "1 Month"
        var chatRoomEnabled: Bool = false
        var announcement: String = ""
        
        // 获取当前所有图片URL（包括临时和已上传的）
        var allImageUrls: [String] {
            imageUrls + (draftImages.compactMap { $0.serverUrl })
        }
        
        // 内部位置信息结构
        struct LocationInfo: Codable {
            var name: String
            var address: String?
            var latitude: Double
            var longitude: Double
            
            init(name: String = "", address: String? = nil, latitude: Double = 0, longitude: Double = 0) {
                self.name = name
                self.address = address
                self.latitude = latitude
                self.longitude = longitude
            }
            
            init(from placemark: MKPlacemark) {
                self.name = placemark.name ?? ""
                self.address = placemark.formattedAddress // 使用扩展方法获取格式化地址
                self.latitude = placemark.coordinate.latitude
                self.longitude = placemark.coordinate.longitude
            }
            
            var coordinate: CLLocationCoordinate2D {
                CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
        }
    }
    
    // 更新 createFromDraft 方法以处理新的图片结构
    static func createFromDraft(_ draft: Draft) -> LocationPost {
        // 合并所有图片URL
        let allImageUrls = draft.allImageUrls
        
        return LocationPost(
            id: UUID().uuidString,
            title: draft.title,
            content: draft.content,
            authorName: "当前用户", // 需要从用户系统获取
            locationName: draft.location.name,
            latitude: draft.location.latitude,
            longitude: draft.location.longitude,
            imageNames: allImageUrls, // 使用合并后的图片URLs
            avatarImage: "default_avatar", // 需要从用户系统获取
            tags: draft.tags,
            participantsCount: 0,
            postedTime: "刚创",
            remainingDays: draft.selectedDuration,
            publishDate: Date().formatted(),
            joinedCount: "0",
            isSponsored: false,
            isLiked: false,
            cachedDistance: nil,
            sponsored: false
        )
    }
}


extension CLPlacemark {
    // 添加一个扩展方法来获取格式化的地址
    var formattedAddress: String {
        var components: [String] = []
        
        // 添加地址组件
        if let subLocality = self.subLocality {
            components.append(subLocality)
        }
        if let locality = self.locality {
            components.append(locality)
        }
        if let administrativeArea = self.administrativeArea {
            components.append(administrativeArea)
        }
        
        return components.joined(separator: ", ")
    }
}
