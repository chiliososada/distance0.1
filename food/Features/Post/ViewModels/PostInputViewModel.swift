
import SwiftUI
import Combine
import CoreLocation


// MARK: - Constants
private enum Layout {
    static let avatarSize: CGFloat = 40
    static let toolbarHeight: CGFloat = 44
    static let maxCharacterCount = 777
    static let maxTitleLength = 20
   
}
// MARK: - View Model
final class PostInputViewModel: ObservableObject {
    // 添加标签相关状态
      @Published var isShowingHashtagSelector = false
      @Published var suggestedTags = [
          "#Meme",
          "#ClassicIndependenceDayMovies",
          "#foodie",
          "#photography",
          "#InternationalCatDay"
      ]
      
    // 现有的属性
        @Published var title = "" {
            didSet {
                if title.count > Layout.maxTitleLength {
                    title = String(title.prefix(Layout.maxTitleLength))
                }
            }
        }
        @Published var content = ""
        @Published var isKeyboardVisible = false
        @Published var keyboardHeight: CGFloat = 0
        @Published var selectedTags: [String] = []
        @Published var showSecondView = false
        @Published var selectedImages: [UIImage] = []
        @Published var userLocationText = ""
        @Published var isShowingImagePicker = false
        @Published var showingPicker =  false {
            didSet {
                // 当显示 picker 时，暂时移除键盘观察者
                if showingPicker {
                    removeKeyboardObservers()
                } else {
                    // 当 picker 关闭时，重新添加键盘观察者
                    setupKeyboardObservers()
                }
            }
        }
        @Published var isLocationPickerActive = false
        
        // 添加表情相关的属性
        @Published var isShowingEmojiPicker = false
        @Published var contentSelectedRange: NSRange?
        
        private var previousLocation: CLLocation?
        let locationManager = LocationManager.shared
        private var keyboardObservers: [NSObjectProtocol] = []
        

    
    private var tagDeleteObserver: NSObjectProtocol?
    
    // 添加焦点追踪
       @Published var focusedField: FocusField?
     
       enum FocusField {
            case title
            case content
        }
        
         var shouldShowToolbar: Bool {
             return focusedField == .content || isShowingHashtagSelector
       }
    
    
    // 简化插入标签的方法
      func insertHashtag(_ tag: String) {
          guard tag.hasPrefix("#") else { return }
          // 只添加到已选标签列表（如果还没有这个标签）
          if !selectedTags.contains(tag) {
              selectedTags.append(tag)
          }
          // 关闭选择器
          isShowingHashtagSelector = false
      }
        
    // 简化删除标签的方法
        func removeTag(_ tag: String) {
            selectedTags.removeAll { $0 == tag }
        }
    // 仍然保留标签选择器的触发检查，但只用于工具栏按钮
        func showHashtagSelector() {
            isShowingHashtagSelector = true
        }
    // 检查是否应该显示标签选择器
    func checkForHashtagTrigger(in text: String) {
        withAnimation(.easeInOut(duration: 0.25)) {
            if let lastChar = text.last, lastChar == "#" {
                isShowingHashtagSelector = true
            } else {
                // 如果删除了 # 或输入了空格，关闭选择器
                isShowingHashtagSelector = false
            }
        }
    }
    
    
    
    
    // 更新表情插入逻辑
    func insertEmoji(_ emoji: String) {
        if content.isEmpty {
            // 第一次插入（内容为空）的情况
            content = emoji
            contentSelectedRange = NSRange(location: emoji.utf16.count, length: 0)
            return
        }
        
        guard let selectedRange = contentSelectedRange else {
            // 没有选中范围，但内容不为空的情况
            content.append(emoji)
            contentSelectedRange = NSRange(location: content.utf16.count, length: 0)
            return
        }
        
        // 有选中范围的情况
        let utf16Start = content.utf16.index(content.utf16.startIndex, offsetBy: selectedRange.location)
        let utf16End = content.utf16.index(utf16Start, offsetBy: selectedRange.length)
        
        guard let start = String.Index(utf16Start, within: content),
              let end = String.Index(utf16End, within: content) else {
            return
        }
        
        let range = start..<end
        content.replaceSubrange(range, with: emoji)
        
        let newLocation = selectedRange.location + emoji.utf16.count
        contentSelectedRange = NSRange(location: newLocation, length: 0)
    }
       
         func showLocationPicker() {
             
             // 移除键盘观察者
                     removeKeyboardObservers()
                     
                     // 确保键盘收起并重置状态
                     isKeyboardVisible = false
                     keyboardHeight = 0
           isLocationPickerActive = true
           // 确保键盘收起
           UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                         to: nil, from: nil, for: nil)
           // 延迟显示选择器，确保键盘完全收起
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
               self.showingPicker = true
           }
       }
     
        
        var characterCount: Int {
            content.count
        }
        
     
    init() {
           setupKeyboardObservers()
           // 初始化时获取位置
           updateLocationText()
        
      
       }
    
    deinit {
        removeKeyboardObservers()
        if let observer = tagDeleteObserver {
                    NotificationCenter.default.removeObserver(observer)
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
                
                var components: [String] = []
                
                if let subLocality = placemark.subLocality, !subLocality.isEmpty {
                    components.append(subLocality)
                }
                if let locality = placemark.locality, !locality.isEmpty {
                    components.append(locality)
                }
                if let area = placemark.administrativeArea, !area.isEmpty {
                    components.append(area)
                }
                
                DispatchQueue.main.async {
                    self.userLocationText = components.joined(separator: ", ")
                }
            }
        }
     func setupKeyboardObservers() {
        
        // 移除现有观察者
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

         // 同样修改显示键盘的观察者
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
    
}
