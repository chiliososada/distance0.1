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

