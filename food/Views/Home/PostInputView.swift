//
//  PostInputView.swift
//  food
//
//  Created by toyousoft on 2024/10/29.
//

import SwiftUI
import PhotosUI
import MapItemPicker


// MARK: - Constants
private enum Layout {
    static let avatarSize: CGFloat = 40
    static let toolbarHeight: CGFloat = 44
    static let maxCharacterCount = 777
    static let maxTitleLength = 20
}

// MARK: - View Model
final class PostInputViewModel: ObservableObject {
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
        @Published var showingPicker = false
        @Published var isLocationPickerActive = false
        
        // 添加表情相关的属性
        @Published var isShowingEmojiPicker = false
        @Published var contentSelectedRange: NSRange?
        
        private var previousLocation: CLLocation?
        let locationManager = LocationManager.shared
        private var keyboardObservers: [NSObjectProtocol] = []
        
    // 添加焦点追踪
       @Published var focusedField: FocusField?
     
       enum FocusField {
            case title
            case content
        }
        
         var shouldShowToolbar: Bool {
           return focusedField == .content
       }
    // 更新表情插入逻辑
        func insertEmoji(_ emoji: String) {
            guard let selectedRange = contentSelectedRange else {
                // 如果没有选中范围，追加到末尾
                content.append(emoji)
                contentSelectedRange = NSRange(location: content.count, length: 0)
                return
            }
            
            // 将 NSRange 转换为 String.Index
            let utf16Start = content.utf16.index(content.utf16.startIndex, offsetBy: selectedRange.location)
            let utf16End = content.utf16.index(utf16Start, offsetBy: selectedRange.length)
            
            // 获取对应的 String.Index
            guard let start = String.Index(utf16Start, within: content),
                  let end = String.Index(utf16End, within: content) else {
                return
            }
            
            // 在正确的位置插入表情
            let range = start..<end
            content.replaceSubrange(range, with: emoji)
            
            // 更新光标位置
            let newLocation = selectedRange.location + emoji.utf16.count
            contentSelectedRange = NSRange(location: newLocation, length: 0)
        }
       
         func showLocationPicker() {
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
    private func setupKeyboardObservers() {
        let showObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            withAnimation(.easeOut(duration: 0.25)) {
                self?.isKeyboardVisible = true
                self?.keyboardHeight = keyboardFrame.height
            }
        }
        
        let hideObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            withAnimation(.easeOut(duration: 0.25)) {
                self?.isKeyboardVisible = false
                self?.keyboardHeight = 0
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

// MARK: - Main View
struct PostInputView: View {
    @StateObject private var viewModel = PostInputViewModel()
      @Environment(\.dismiss) private var dismiss
      @Binding var isPresented: Bool
      @Binding var selectedTab: Int
      @FocusState private var focusedField: PostInputViewModel.FocusField?
    
    
    private enum Layout {
           static let spacing: CGFloat = 16
           static let toolbarHeight: CGFloat = 44
           static let maxCharacterCount = 777
       }
   
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: Layout.spacing) {
                        if !viewModel.selectedImages.isEmpty {
                            imageSection
                                .padding(.top)
                        }
                        
                        titleInputSection
                        
                        Divider()
                            .padding(.horizontal)
                        
                        locationSection
                        
                        contentInputSection
                        
                        tagsSection
                    }
                    .padding(.bottom, viewModel.keyboardHeight > 0 ? viewModel.keyboardHeight - 50 : 0)
                }
                
                if viewModel.shouldShowToolbar{
                    toolbarSection
                        .transition(.move(edge: .bottom))
                }
            }
            .onChange(of: focusedField) { newValue in
                      viewModel.focusedField = newValue
                  }
            .sheet(isPresented: $viewModel.isShowingImagePicker) {
                MultiImagePicker(images: $viewModel.selectedImages)
            }
            .sheet(isPresented: $viewModel.isShowingEmojiPicker) {
                EmojiPickerView(
                    onEmojiSelected: { emoji in
                        viewModel.insertEmoji(emoji)
                    },
                    isPresented: $viewModel.isShowingEmojiPicker
                )
                .presentationDetents([.height(350)])
            }
            
            .mapItemPicker(isPresented: $viewModel.showingPicker) { item in
                if let name = item?.placemark.name {
                    viewModel.userLocationText = name
                }
            }
            
            .navigationBarItems(
                leading: dismissButton,
                trailing: publishButton
            )
        }
    }
    private func dismissKeyboard() {
          focusedField = nil
          UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
      }
    private var titleInputSection: some View {
          HStack {
              TextField("标题", text: $viewModel.title)
                  .font(.system(size: 18, weight: .medium))
                  .focused($focusedField, equals: .title)
                                  .onChange(of: focusedField) { newValue in
                                      viewModel.focusedField = newValue
                                  }
              if !viewModel.title.isEmpty {
                  Button(action: { viewModel.title = "" }) {
                      Image(systemName: "xmark.circle.fill")
                          .foregroundColor(.gray)
                  }
              }
              
              Text("\(viewModel.title.count)/\(20)")
                  .font(.system(size: 12))
                  .foregroundColor(.gray)
                  .frame(width: 40)
          }
          .padding(.horizontal)
          .padding(.top, Layout.spacing)
      }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if !viewModel.userLocationText.isEmpty {
                    Text("发送到这里:")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        viewModel.showLocationPicker()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.blue)
                            Text(viewModel.userLocationText)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    // 图片展示区域
       private var imageSection: some View {
           ScrollView(.horizontal, showsIndicators: false) {
               HStack(spacing: 10) {
                   ForEach(viewModel.selectedImages.indices, id: \.self) { index in
                       ImageTile(
                           image: viewModel.selectedImages[index],
                           onDelete: {
                               viewModel.selectedImages.remove(at: index)
                           }
                       )
                   }
               }
               .padding(.horizontal)
           }
       }
    private var dismissButton: some View {
        Button(action: {
            dismiss()
            selectedTab = 0
        }) {
            Image(systemName: "xmark")
                .font(.title2)
                .foregroundColor(.black)
        }
    }
    
    private var publishButton: some View {
        Button(action: { viewModel.showSecondView = true }) {
            Text("发布")
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .foregroundColor(.white)
                .background(Color.black)
                .cornerRadius(25)
        }
    }
    

    
    private var contentInputSection: some View {
        CustomTextView(
            text: $viewModel.content,
            selectedRange: $viewModel.contentSelectedRange,
            focusedField: $viewModel.focusedField
        )
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(minHeight: 300)
        .padding(.horizontal)
    }
    
    private var tagsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            if !viewModel.selectedTags.isEmpty {
                HStack(spacing: 8) {
                    ForEach(viewModel.selectedTags, id: \.self) { tag in
                        tagView(tag)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var toolbarSection: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 24) {
                Button(action: { viewModel.isShowingImagePicker = true }) {
                                  Image(systemName: "photo")
                                      .foregroundColor(.black)
                              }
                
                Button(action: { viewModel.isShowingEmojiPicker = true }) {
                               Image(systemName: "face.smiling")
                                   .foregroundColor(.black)
                           }
                
                Button(action: { /* 话题选择 */ }) {
                    Image(systemName: "number")
                        .foregroundColor(.black)
                }
            
               
                
                Spacer()
                // 添加键盘收起按钮
                             Button(action: dismissKeyboard) {
                                 Image(systemName: "keyboard.chevron.compact.down.fill")
                                     .foregroundColor(.black)
                             }
                Text("\(viewModel.characterCount)/\(Layout.maxCharacterCount)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .frame(height: Layout.toolbarHeight)
            .background(Color(UIColor.systemBackground))
        }
    }
    
    private func tagView(_ tag: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "pencil")
            Text(tag)
        }
        .font(.system(size: 14))
        .foregroundColor(.gray)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}
// 图片展示组件
struct ImageTile: View {
    let image: UIImage
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .cornerRadius(8)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.red))
                    .shadow(radius: 2)
            }
            .padding(5)
        }
    }
}

// 图片选择器
struct MultiImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 6 - images.count
        // 设置预期的图片质量
        config.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: MultiImagePicker
        
        init(_ parent: MultiImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            let group = DispatchGroup()
            var loadedImages: [(Int, UIImage)] = []
            
            for (index, result) in results.enumerated() {
                group.enter()
                
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                        defer { group.leave() }
                        
                        if let error = error {
                            print("Error loading image: \(error.localizedDescription)")
                            return
                        }
                        
                        if let uiImage = image as? UIImage {
                            // 压缩图片
                            if let compressedImage = self?.compressImage(uiImage) {
                                loadedImages.append((index, compressedImage))
                            }
                        }
                    }
                } else {
                    group.leave()
                }
            }
            
            group.notify(queue: .main) { [weak self] in
                // 按原始顺序排序并添加图片
                let sortedImages = loadedImages.sorted { $0.0 < $1.0 }.map { $0.1 }
                self?.parent.images.append(contentsOf: sortedImages)
            }
        }
        
        private func compressImage(_ image: UIImage) -> UIImage {
            let maxSize: CGFloat = 1024 // 最大尺寸
            let compressionQuality: CGFloat = 0.7 // 压缩质量
            
            // 调整图片尺寸
            let size = image.size
            let scale = min(maxSize/size.width, maxSize/size.height, 1)
            let newSize = CGSize(width: size.width * scale, height: size.height * scale)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
            defer { UIGraphicsEndImageContext() }
            
            image.draw(in: CGRect(origin: .zero, size: newSize))
            
            guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
                return image
            }
            
            // 压缩图片数据
            if let data = resizedImage.jpegData(compressionQuality: compressionQuality),
               let compressedImage = UIImage(data: data) {
                return compressedImage
            }
            
            return resizedImage
        }
    }
}
// MARK: - Preview
struct PostInputView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PostInputView(
                isPresented: .constant(true),
                selectedTab: .constant(0)
            )
        }
    }
}


