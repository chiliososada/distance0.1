import SwiftUI
import PhotosUI
import MapItemPicker

struct PostInputView: View {
    @State private var titleText: String = ""
    @State private var bodyText: String = ""
    @Binding var isPresented: Bool
    @Binding var selectedTab: Int // 用于控制跳转到主页的 Tab
       
    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var tabBarManager: TabBarManager
    
    
    @FocusState private var isTextFieldFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    @State private var offset: CGFloat = 0
    @State private var showSecondView = false
    @State private var selectedLocation: NearbyLocationData?
    @State private var tagsInput: String = "" // 输入的标签
    @State private var tags: [String] = [] // 存储的标签
    private let maxTags = 3 // 最大标签数量

    // 图片选择相关状态
    @State private var selectedImages: [UIImage] = []
    @State private var isShowingImagePicker = false

    
    //
    @State private var showingPicker = false
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) { // 减小了 `spacing`
                        Button("Choose location") {
                                   showingPicker = true
                               }
                               .mapItemPicker(isPresented: $showingPicker) { item in
                                   if let name = item?.name {
                                       print("Selected \(name)")
                                   }
                               }
                        // 1. 位置信息展示
                        if let location = selectedLocation {
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.title)
                                    .foregroundColor(.red)
                                Text(location.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            .padding([.top, .horizontal])
                        }
                        
                        // 2. 图片选择和展示部分
                        VStack(alignment: .leading, spacing: 8) {
                            Text("添加图片 (最多6张)")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    // 展示已选图片，并带有删除按钮
                                    ForEach(selectedImages.indices, id: \.self) { index in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: selectedImages[index])
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .cornerRadius(8)
                                            
                                            // "X" 按钮，点击后删除图片
                                            Button(action: {
                                                selectedImages.remove(at: index) // 删除选中的图片
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.white)
                                                    .background(Circle().fill(Color.red).frame(width: 24, height: 24)) // 调整背景圆形
                                                    .shadow(radius: 2) // 添加阴影
                                            }
                                            .padding(5) // 增加外边距，确保 "X" 按钮不被裁剪
                                        }
                                    }
                                    
                                    // 添加图片按钮 (最多6张)
                                    if selectedImages.count < 6 {
                                        Button(action: {
                                            isShowingImagePicker = true // 显示图片选择器
                                        }) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5])) // 添加虚线边框
                                                    .frame(width: 100, height: 100)
                                                    .foregroundColor(.blue)
                                                Image(systemName: "plus")
                                                    .font(.title)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        Divider()
                            .padding(.horizontal)
                        
                        // 3. 标题输入框
                        VStack(alignment: .leading) {
                            Text("标题")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            TextField("请输入标题", text: $titleText)
                                .padding(.vertical, 6) // 减少标题输入框的高度
                                .padding(.horizontal)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5])) // 添加虚线边框
                                        .foregroundColor(.blue)
                                )
                                .padding(.horizontal)
                        }

                        // 标签展示
                        if !tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(tags, id: \.self) { tag in
                                        HStack(spacing: 8) {
                                            Text("#\(tag)")
                                                .foregroundColor(.black)
                                                .padding(.vertical, 4) // 减少标签的高度
                                                .padding(.horizontal, 8)
                                                .background(Color.blue.opacity(0.2))
                                                .cornerRadius(8)
                                            
                                            // 删除标签按钮
                                            Button(action: {
                                                removeTag(tag)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                        .padding(.horizontal, 4)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        Divider()
                            .padding(.horizontal)
                        
                        // 标签输入框
                        VStack(alignment: .leading) {
                            // 只有在标签数量小于最大值时才显示输入框
                            if tags.count < maxTags {
                                TextField("添加标签", text: $tagsInput, onCommit: {
                                    addTag() // 按回车时，添加标签
                                })
                                .padding(.vertical, 6) // 减少标签输入框的高度
                                .padding(.horizontal)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5])) // 添加虚线边框
                                        .foregroundColor(.blue)
                                )
                                .padding(.horizontal)
                            } else {
                                Text("最多只能添加 \(maxTags) 个标签")
                                    .foregroundColor(.red)
                                    .padding(.horizontal)
                            }
                        }

                        Divider()
                            .padding(.horizontal)

                        // 5. 正文输入框
                        VStack(alignment: .leading) {
                            Text("正文")
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.top, -10) // 将正文部分上移

                            TextEditor(text: $bodyText)
                                .padding(.vertical, 8) // 减少 TextEditor 的 padding
                                .frame(minHeight: 320)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5])) // 添加虚线边框
                                        .foregroundColor(.blue)
                                )
                                .padding(.horizontal)
                        }

                        Spacer()
                    }
                    .padding(.bottom, keyboardHeight)
                    .onChange(of: keyboardHeight) {
                        scrollToActiveTextField()
                    }
                }
            }
            .onAppear {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isTextFieldFocused = true
                }
                self.subscribeToKeyboardEvents()
                
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(self)
                
            }

            .sheet(isPresented: $isShowingImagePicker) {
                // 调用多图片选择的图片选择器
                MultiImagePicker(images: $selectedImages)
            }
            .navigationBarItems(
                leading: Button(action: {
//                    isPresented = false
                    dismiss() // 关闭当前发布视图
                    selectedTab = 0 // 切换到主页 Tab (假设主页的 tag 是 0)
                    
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.black)
                },
                trailing: Button("Next") {
                    showSecondView.toggle()
                }
                .font(.headline)
                .foregroundColor(.black)
            )
            .fullScreenCover(isPresented: $showSecondView) {
                PostInputLocation(onLocationSelected: { location in
                    self.selectedLocation = location
                }, isPresented: $showSecondView)
            }
            
        }
    }

    // 添加标签
    private func addTag() {
        let trimmedTag = tagsInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) && tags.count < maxTags {
            tags.append(trimmedTag)
        }
        DispatchQueue.main.async {
            tagsInput = "" // 使用异步操作清空输入框
        }
    }

    // 删除标签
    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }

    // 监听键盘事件
    private func subscribeToKeyboardEvents() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation {
                    self.keyboardHeight = keyboardFrame.height - 10
                }
            }
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation {
                self.keyboardHeight = 0
            }
        }
    }

    // 滚动到输入框可见区域
    private func scrollToActiveTextField() {
        DispatchQueue.main.async {
            withAnimation {
                self.offset = self.keyboardHeight
            }
        }
    }
}

// 使用 PHPickerViewController 来选择多张图片
struct MultiImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images // 仅允许选择图片
        config.selectionLimit = 6 - images.count // 限制最大选择数量
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

            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                        if let uiImage = image as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.images.append(uiImage)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct PostInputView_Previews: PreviewProvider {
    static var previews: some View {
        PostInputView(
            isPresented: .constant(true),
            selectedTab: .constant(0) // 预览时设置 selectedTab 的默认值
        )
       
    }
}
