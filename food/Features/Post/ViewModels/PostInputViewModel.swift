import SwiftUI
import Combine
import CoreLocation
import MapKit


typealias DraftImage = LocationPost.Draft.DraftImage

// MARK: - Constants
private enum Layout {
    static let avatarSize: CGFloat = 40
    static let toolbarHeight: CGFloat = 44
    static let maxCharacterCount = 777
    static let maxTitleLength = 20
    static let maxImages = 6  // 添加最大图片数量限制
    
}

// MARK: - View Model
final class PostInputViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var draft = LocationPost.Draft()
    @Published var selectedImages: [UIImage] = []
    
    // UI 状态
    @Published var isShowingHashtagSelector = false
    @Published var suggestedTags = [
        "#Meme",
        "#ClassicIndependenceDayMovies",
        "#foodie",
        "#photography",
        "#InternationalCatDay"
    ]
    
    @Published var isKeyboardVisible = false
    @Published var keyboardHeight: CGFloat = 0
    @Published var showSecondView = false
    @Published var isShowingImagePicker = false
    @Published var showingPicker = false {
        didSet {
            if showingPicker {
                removeKeyboardObservers()
            } else {
                setupKeyboardObservers()
            }
        }
    }
    @Published var isLocationPickerActive = false
    @Published var isShowingEmojiPicker = false
    @Published var overallProgress: Double = 0.0  
    @Published var contentSelectedRange: NSRange?
    @Published var focusedField: FocusField?
    
    // 发布设置状态
    @Published var showingDurationInfo = false
    @Published var showingChatInfo = false
    
    // 发布状态
    @Published var isPublishing = false
    @Published var showPublishSuccess = false
    @Published var showPublishError = false
    @Published var errorMessage: String = ""  // 添加错误消息属性
    
    // MARK: - Private Properties
    private var previousLocation: CLLocation?
    private let locationManager = LocationManager.shared
    private var keyboardObservers: [NSObjectProtocol] = []
    private var tagDeleteObserver: NSObjectProtocol?
    
    // MARK: - Computed Properties
    var characterCount: Int {
        draft.content.count
    }
    
    var shouldShowToolbar: Bool {
        return focusedField == .content || isShowingHashtagSelector
    }
    
    // MARK: - Enums
    enum FocusField {
        case title
        case content
    }
    
    var canAddMoreImages: Bool {
            selectedImages.count < Layout.maxImages
    }
    
    // MARK: - Tag Management
    func insertHashtag(_ tag: String) {
        guard tag.hasPrefix("#") else { return }
        if !draft.tags.contains(tag) {
            draft.tags.append(tag)
        }
        isShowingHashtagSelector = false
    }
    
    func removeTag(_ tag: String) {
        draft.tags.removeAll { $0 == tag }
    }
    
    func showHashtagSelector() {
        isShowingHashtagSelector = true
    }
    
    func checkForHashtagTrigger(in text: String) {
        withAnimation(.easeInOut(duration: 0.25)) {
            isShowingHashtagSelector = text.last == "#"
        }
    }
    
    // MARK: - Emoji Handling
    func insertEmoji(_ emoji: String) {
        if draft.content.isEmpty {
            draft.content = emoji
            contentSelectedRange = NSRange(location: emoji.utf16.count, length: 0)
            return
        }
        
        guard let selectedRange = contentSelectedRange else {
            draft.content.append(emoji)
            contentSelectedRange = NSRange(location: draft.content.utf16.count, length: 0)
            return
        }
        
        let utf16Start = draft.content.utf16.index(draft.content.utf16.startIndex, offsetBy: selectedRange.location)
        let utf16End = draft.content.utf16.index(utf16Start, offsetBy: selectedRange.length)
        
        guard let start = String.Index(utf16Start, within: draft.content),
              let end = String.Index(utf16End, within: draft.content) else {
            return
        }
        
        let range = start..<end
        draft.content.replaceSubrange(range, with: emoji)
        
        let newLocation = selectedRange.location + emoji.utf16.count
        contentSelectedRange = NSRange(location: newLocation, length: 0)
    }
    
    // MARK: - Location Management
    func showLocationPicker() {
        removeKeyboardObservers()
        isKeyboardVisible = false
        keyboardHeight = 0
        isLocationPickerActive = true
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                      to: nil, from: nil, for: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showingPicker = true
        }
    }
    
    func handleMapItemSelection(_ mapItem: MKMapItem?) {
        if let placemark = mapItem?.placemark {
            draft.location = LocationPost.Draft.LocationInfo(from: placemark)
        }
    }
    
    // MARK: - Draft Management
    func showDraftActionSheet() -> Bool {
        return !draft.title.isEmpty ||
               !draft.content.isEmpty ||
               !draft.tags.isEmpty ||
               !selectedImages.isEmpty
    }
    
    func saveDraft() {
       
        if let encoded = try? JSONEncoder().encode(draft) {
            UserDefaults.standard.set(encoded, forKey: "location_post_draft")
        }
    }
    
    func loadDraft() {
          guard let data = UserDefaults.standard.data(forKey: "location_post_draft"),
                let savedDraft = try? JSONDecoder().decode(LocationPost.Draft.self, from: data) else {
              return
          }
          
          draft = savedDraft
          
          // 加载图片：从 draftImages 中加载
          selectedImages = draft.draftImages.compactMap { draftImage in
              DraftImageManager.shared.loadImage(identifier: draftImage.localIdentifier)
          }
      }
    
    func clearDraft() {
            // 清理本地存储的图片
            draft.draftImages.forEach { draftImage in
                DraftImageManager.shared.deleteImage(identifier: draftImage.localIdentifier)
            }
            
            UserDefaults.standard.removeObject(forKey: "location_post_draft")
            draft = LocationPost.Draft()
            selectedImages.removeAll()
        }
   
   
    // PostInputViewModel.swift 中的修改部分

    // 在 PostInputViewModel 中修改

    func handleImageSelection(_ newImages: [UIImage]) {
            // 检查是否已达到最大数量
            if !canAddMoreImages {
                errorMessage = "最多只能上传\(Layout.maxImages)张图片"
                showPublishError = true
                return
            }
            
            print("handleImageSelection called with \(newImages.count) new images")
            print("Current selected images: \(selectedImages.count)")
            
            // 如果选择的新图片会超过限制，截取允许的数量
            let availableSlots = Layout.maxImages - selectedImages.count
            let imagesToProcess = newImages.prefix(availableSlots)
            
            isPublishing = true
            overallProgress = 0
            
            let oldIdentifiers = draft.draftImages.map { $0.localIdentifier }
            
            let group = DispatchGroup()
            var newDraftImages: [(Int, DraftImage)] = []
            var newSelectedImages: [(Int, UIImage)] = []
            
            for (index, image) in imagesToProcess.enumerated() {
                group.enter()
                print("Processing new image \(index + 1)")
                
                DispatchQueue.global(qos: .userInitiated).async {
                    if let identifier = DraftImageManager.shared.saveImage(image) {
                        print("Successfully saved image \(index + 1) with identifier: \(identifier)")
                        let draftImage = DraftImage(
                            localIdentifier: identifier,
                            uploadStatus: .draft
                        )
                        newDraftImages.append((index, draftImage))
                        newSelectedImages.append((index, image))
                    } else {
                        print("Failed to save image \(index + 1)")
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) { [weak self] in
                guard let self = self else {
                    print("Self was deallocated in completion handler")
                    return
                }
                
                print("All new image processing completed")
                
                // 按索引排序
                let sortedDraftImages = newDraftImages.sorted { $0.0 < $1.0 }.map { $0.1 }
                let sortedSelectedImages = newSelectedImages.sorted { $0.0 < $1.0 }.map { $0.1 }
                
                // 设置新的图片数组（保留现有图片并添加新图片）
                self.draft.draftImages.append(contentsOf: sortedDraftImages)
                self.selectedImages.append(contentsOf: sortedSelectedImages)
                
                if !sortedDraftImages.isEmpty {
                    self.saveDraft()
                    print("Draft saved successfully")
                }
                
                self.isPublishing = false
                self.overallProgress = 0
                print("Image selection handling completed. Total images: \(self.selectedImages.count)")
            }
        }
    
    
    private func validateImages() -> Bool {
            // 检查是否所有图片都存在
            let allImagesValid = draft.draftImages.allSatisfy { draftImage in
                DraftImageManager.shared.imageExists(identifier: draftImage.localIdentifier)
            }
            
            if !allImagesValid {
                errorMessage = "部分图片已丢失，请重新选择"
                showPublishError = true
                return false
            }
            
            return true
        }
    func hasDraft() -> Bool {
        return UserDefaults.standard.data(forKey: "location_post_draft") != nil
    }
   
    
    func removeImage(at index: Int) {
          guard index < selectedImages.count && index < draft.draftImages.count else { return }
          
          let draftImage = draft.draftImages[index]
          DraftImageManager.shared.deleteImage(identifier: draftImage.localIdentifier)
          
          draft.draftImages.remove(at: index)
          selectedImages.remove(at: index)
          
          saveDraft()
      }

    // 发布错误类型
    enum PublishError: LocalizedError {
        case emptyTitle
        case emptyContent
        case emptyLocation
        case uploadFailed
        case publishFailed
        case titleTooLong
        case contentTooLong
        
        var errorDescription: String? {
            switch self {
            case .emptyTitle:
                return "标题不能为空"
            case .emptyContent:
                return "内容不能为空"
            case .emptyLocation:
                return "请选择位置"
            case .uploadFailed:
                return "图片上传失败"
            case .publishFailed:
                return "发布失败"
            case .titleTooLong:
                return "标题最多20个字符"
            case .contentTooLong:
                return "内容最多777个字符"
            }
        }
    }
    // 图片上传方法
    private func uploadImage(localIdentifier: String) async throws -> String {
        guard let image = DraftImageManager.shared.loadImage(identifier: localIdentifier) else {
            throw PublishError.uploadFailed
        }
        
        // TODO: 实现实际的图片上传API调用
        // 这里应该是您的图片上传逻辑
        // 返回服务器图片URL
        return "https://example.com/images/\(UUID().uuidString).jpg"
    }
    
    
  
    private func uploadImages() async throws -> [String] {
        var uploadedUrls: [String] = []
        
        for draftImage in draft.draftImages {
            guard let image = DraftImageManager.shared.loadImage(identifier: draftImage.localIdentifier) else {
                continue
            }
            
            // 模拟上传，实际使用时替换为真实的上传代码
            try await Task.sleep(nanoseconds: 1_000_000_000) // 等待1秒
            let imageUrl = "https://example.com/images/\(UUID().uuidString).jpg"
            uploadedUrls.append(imageUrl)
        }
        
        return uploadedUrls
    }
    
    
    
    
   
    
    private func publishPost(_ post: LocationPost) async throws {
        // TODO: 实现实际的发布API调用
        // 这里应该是您的发布逻辑
        
        // 模拟网络延迟
        try await Task.sleep(nanoseconds: 1_500_000_000)
    }
    // MARK: - Publishing
    func publishBlog(completion: @escaping (Bool) -> Void) {
            Task {
                do {
                    guard !isPublishing else { return }
                    isPublishing = true
                    
                    // 1. 验证基本信息
                    try validateBasicInfo()
                    
                    // 2. 验证图片
                    guard validateImages() else {
                        throw PublishError.uploadFailed
                    }
                    
                    // 3. 上传图片
                    let uploadedUrls = try await uploadImages()
                    draft.imageUrls = uploadedUrls
                    
                    // 4. 发布帖子
                    let post = LocationPost.createFromDraft(draft)
                    try await publishPost(post)
                    
                    await MainActor.run {
                        self.isPublishing = false
                        self.showPublishSuccess = true
                        self.errorMessage = ""
                        self.clearDraft()
                        completion(true)
                    }
                } catch {
                    await MainActor.run {
                        self.isPublishing = false
                        self.showPublishError = true
                        if let publishError = error as? PublishError {
                            self.errorMessage = publishError.errorDescription ?? "发布失败"
                        } else {
                            self.errorMessage = error.localizedDescription
                        }
                        completion(false)
                    }
                }
            }
        }
    private func validateBasicInfo() throws {
            guard !draft.title.isEmpty else { throw PublishError.emptyTitle }
            guard !draft.content.isEmpty else { throw PublishError.emptyContent }
            guard !draft.location.name.isEmpty else { throw PublishError.emptyLocation }
            
            // 添加字数限制验证
            guard draft.title.count <= Layout.maxTitleLength else {
                throw PublishError.titleTooLong
            }
            guard draft.content.count <= Layout.maxCharacterCount else {
                throw PublishError.contentTooLong
            }
        }
    // MARK: - Keyboard Management
    func setupKeyboardObservers() {
        removeKeyboardObservers()
        
        let hideObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.25)) {
                    self?.isKeyboardVisible = false
                    self?.keyboardHeight = 0
                }
            }
        }
        
        let showObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.25)) {
                    self?.isKeyboardVisible = true
                    self?.keyboardHeight = keyboardFrame.height
                }
            }
        }
        
        keyboardObservers = [showObserver, hideObserver]
    }
    
    private func removeKeyboardObservers() {
        keyboardObservers.forEach {
            NotificationCenter.default.removeObserver($0)
        }
        keyboardObservers.removeAll()
    }
    
    // MARK: - Initialization
    init() {
        setupKeyboardObservers()
        checkAndLoadDraft()
        // 如果没有位置信息，尝试获取当前位置
            if draft.location.name.isEmpty {
                updateLocationText()
            }
    }
    
    deinit {
        removeKeyboardObservers()
        if let observer = tagDeleteObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - Draft Loading
    private func checkAndLoadDraft() {
        if hasDraft() {
            loadDraft()
        }
    }
    func updateLocationText() {
            guard let location = locationManager.userLocation else { return }
            
            if let previous = previousLocation,
               location.distance(from: previous) < 100 { return }
            
            previousLocation = location
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
                guard let self = self,
                      let placemark = placemarks?.first else { return }
                
                // 如果用户还没有选择位置，使用当前位置
                if self.draft.location.name.isEmpty {
                    let locationInfo = LocationPost.Draft.LocationInfo(
                        name: placemark.name ?? "",
                        address: placemark.formattedAddress,
                        latitude: placemark.location?.coordinate.latitude ?? 0,
                        longitude: placemark.location?.coordinate.longitude ?? 0
                    )
                    
                    DispatchQueue.main.async {
                        self.draft.location = locationInfo
                    }
                }
            }
        }
    
}

