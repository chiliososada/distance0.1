import Foundation
import UIKit

// MARK: - Post Model
struct Post: Identifiable {
    let id: UUID
    let title: String
    let content: String
    let images: [String]  // 图片URL或名称数组
    let tags: [String]
    let location: String
    let publishDate: Date
    let author: PostAuthor
    var participantsCount: Int
    var distance: Int
    
    // 初始化器
    init(
        title: String,
        content: String,
        images: [String],
        tags: [String],
        location: String,
        publishDate: Date,
        author: PostAuthor,
        participantsCount: Int,
        distance: Int,
        id: UUID = UUID()  // 提供默认值
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.images = images
        self.tags = tags
        self.location = location
        self.publishDate = publishDate
        self.author = author
        self.participantsCount = participantsCount
        self.distance = distance
    }
    
    // 发帖人信息
    struct PostAuthor {
        let id: String
        let name: String
        let avatar: String
    }
    
    // 图片项模型
    struct ImageItem {
        let imageName: String
        let aspectRatio: CGFloat // 宽高比 (width/height)
        
        var isPortrait: Bool { aspectRatio < 1 }
        var isLandscape: Bool { aspectRatio > 1 }
        var isSquare: Bool { abs(aspectRatio - 1.0) < 0.1 }
    }
}

// MARK: - Post Input Form Data
struct PostFormData {
    var title: String = ""
    var content: String = ""
    var selectedImages: [UIImage] = []
    var selectedTags: [String] = []
    var userLocationText: String = ""
    var contentSelectedRange: NSRange?
    
    static let maxTitleLength = 20
    static let maxCharacterCount = 777
    
    // 验证
    var isTitleValid: Bool {
        !title.isEmpty && title.count <= Self.maxTitleLength
    }
    
    var isContentValid: Bool {
        !content.isEmpty && content.count <= Self.maxCharacterCount
    }
    
    var isValid: Bool {
        isTitleValid && isContentValid && !selectedTags.isEmpty
    }
}

// MARK: - Post Input State
final class PostInputState: ObservableObject {
    @Published var formData = PostFormData()
    @Published var isShowingHashtagSelector = false
    @Published var suggestedTags = [
        "#Meme",
        "#ClassicIndependenceDayMovies",
        "#foodie",
        "#photography",
        "#InternationalCatDay"
    ]
    @Published var showSecondView = false
    @Published var isShowingImagePicker = false
    @Published var showingPicker = false
    @Published var isLocationPickerActive = false
    @Published var isShowingEmojiPicker = false
    @Published var keyboardHeight: CGFloat = 0
    @Published var focusedField: FocusField?
    
    enum FocusField {
        case title
        case content
    }
    
    var shouldShowToolbar: Bool {
        focusedField == .content || isShowingHashtagSelector
    }
    
    // MARK: - Sample Data
    static let samplePost = Post(
        title: "周末聚餐",
        content: "这周末有人想一起去尝试新开的餐厅吗？听说他们的特色菜很不错！",
        images: ["food_1", "food_2"],
        tags: ["美食", "社交", "周末"],
        location: "東京都 新宿区",
        publishDate: Date(),
        author: Post.PostAuthor(
            id: "user123",
            name: "美食达人",
            avatar: "avatar_1"
        ),
        participantsCount: 5,
        distance: 500
    )
}
