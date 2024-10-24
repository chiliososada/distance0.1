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
    @State private var previousLocation: CLLocation?
    
    @FocusState private var isTextFieldFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    @State private var offset: CGFloat = 0
    @State private var showSecondView = false
    //    @State private var selectedLocation: NearbyLocationData?
    @State private var tagsInput: String = "" // 输入的标签
    @State private var tags: [String] = [] // 存储的标签
    private let maxTags = 3 // 最大标签数量
    
    // 图片选择相关状态
    @State private var selectedImages: [UIImage] = []
    @State private var isShowingImagePicker = false
    @State private var showingPicker = false
    
    @StateObject private var locationManager = LocationManager.shared
    @State  private var userLocationText: String = "" // 默认位置文本
    
    
    
    
    @Environment(\.presentationMode) var presentationMode // 用于后退功能
    let times = ["1天", "1周", "1月"]
    @State private var selectedTimeIndex = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) { // 减小了 `spacing`
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
                                                    .foregroundColor(.black)
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
                        
                        
                        
                        // 位置
                        VStack(alignment: .leading) {
                            Text("位置")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            HStack(spacing: 2) { // 减少 HStack 的 spacing
                                if !userLocationText.isEmpty {
                                    Image(systemName: "mappin.and.ellipse") // 使用系统图标表示位置
                                        .foregroundColor(.blue) // 可选：设置图标颜色
                                }
                                
                                Text(userLocationText.isEmpty ? "获取位置中..." : userLocationText)
                                    .font(.system(size: 14)) // 设置字体大小为 14
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 0) // 去除左右额外的 padding
                                Spacer()
                                
                                Button("更换位置") {
                                    showingPicker = true
                                }
                                .foregroundColor(.blue)  // 设置文本颜色为白色
                            }
                            .mapItemPicker(isPresented: $showingPicker) { item in
                                if let placemark = item?.placemark {
                                    // 创建一个数组来存储非空的地址部分
                                    var addressComponents: [String] = []
                                    
                                    // 提取地址信息，如果非空则加入数组
                                    if let name = placemark.name, !name.isEmpty {
                                        addressComponents.append(name) // 地点名称，如“京成立石駅”
                                    }
                                    if let locality = placemark.locality, !locality.isEmpty {
                                        addressComponents.append(locality) // 市区，如“東京都葛飾区”
                                    }
                                    if let subLocality = placemark.subLocality, !subLocality.isEmpty {
                                        addressComponents.append(subLocality) // 街道/较小的区划，如“立石”
                                    }
                                    if let administrativeArea = placemark.administrativeArea, !administrativeArea.isEmpty {
                                        addressComponents.append(administrativeArea) // 都道府县，如“東京都”
                                    }
                                    
                                    // 使用 ", " 将非空的地址部分拼接为完整地址
                                    userLocationText = addressComponents.joined(separator: ", ")
                                    
                                    // 提取经纬度
                                    if let location = placemark.location {
                                        let latitude = location.coordinate.latitude
                                        let longitude = location.coordinate.longitude
                                        
                                        // 输出经纬度
                                        print("Latitude: \(latitude), Longitude: \(longitude)")
                                        // 这里可以将 latitude 和 longitude 赋值给你的变量
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("有效时长(可续期)")
                                    .font(.headline)
                                    .padding(.horizontal) // 确保和其他部分对齐
                                Picker(selection: $selectedTimeIndex, label: Text("")) {
                                    ForEach(times.indices, id: \.self) { index in
                                        Text(times[index]).tag(index)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding(.horizontal) // 调整 picker 的 padding 使其和其他元素对齐
                            }
                        }
                        
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
                                        .foregroundColor(.black)
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
                        
                        //                        Divider()
                        //                            .padding(.horizontal)
                        
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
                                        .foregroundColor(.black)
                                )
                                .padding(.horizontal)
                            } else {
                                Text("最多只能添加 \(maxTags) 个标签")
                                    .foregroundColor(.red)
                                    .padding(.horizontal)
                            }
                        }
                        //
                        //                        Divider()
                        //                            .padding(.horizontal)
                        
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
                                        .foregroundColor(.black)
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
                updateLocationText() // 更新位置文本
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
                trailing:
                    Button(action: {
                        showSecondView = true
                    }) {
                        Text("发布")
                            .font(.system(size: 12, weight: .medium)) // 调整字体大小
                            .padding(.horizontal, 16) // 调整左右内边距
                            .padding(.vertical, 6) // 调整上下内边距
                            .foregroundColor(.white)
                            .background(Color.black)
                            .cornerRadius(25) // 调整圆角大小
                    }
                
                // 跳转到新页面
                    .navigationDestination(isPresented: $showSecondView) {
                        
                    }
                
            )
            //            .fullScreenCover(isPresented: $showSecondView) {
            //                PostInputLocation(onLocationSelected: { location in
            //                    self.selectedLocation = location
            //                }, isPresented: $showSecondView)
            //            }
            
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
    private func updateLocationText() {
        guard let location = locationManager.userLocation else {
            print("User location is not available.")
            return
        }
        
        // 如果位置没有显著变化，不执行反向地理编码
        if let previous = previousLocation, location.distance(from: previous) < 100 {
            print("Location hasn't changed significantly.")
            return
        }
        
        // 更新上次的已处理位置
        previousLocation = location
        
        // 开始反向地理编码请求
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Failed to get placemark: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("No placemark found.")
                return
            }
            
            // 更新位置信息逻辑...
            var addressComponents: [String] = []
            
            //            if let name = placemark.name, !name.isEmpty {
            //                addressComponents.append(name)
            //            }
            if let subLocality = placemark.subLocality, !subLocality.isEmpty {
                addressComponents.append(subLocality)
            }
            if let locality = placemark.locality, !locality.isEmpty {
                addressComponents.append(locality)
            }
            if let administrativeArea = placemark.administrativeArea, !administrativeArea.isEmpty {
                addressComponents.append(administrativeArea)
            }
            
            DispatchQueue.main.async {
                userLocationText = addressComponents.joined(separator: ", ")
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
