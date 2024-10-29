//import SwiftUI
//import PhotosUI
//import MapItemPicker
//
//// MARK: - View Model
//final class PostInputViewModel: ObservableObject {
//    @Published var titleText = ""
//    @Published var bodyText = ""
//    @Published var tagsInput = ""
//    @Published var tags: [String] = []
//    @Published var selectedImages: [UIImage] = []
//    @Published var userLocationText = ""
//    @Published var selectedTimeIndex = 0
//    @Published var keyboardHeight: CGFloat = 0
//    @Published var showSecondView = false
//    
//    let maxTags = 3
//    let times = ["1天", "1周", "1月"]
//    private var previousLocation: CLLocation?
//    let locationManager = LocationManager.shared
//    
//    func addTag() {
//        let trimmedTag = tagsInput.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmedTag.isEmpty,
//              !tags.contains(trimmedTag),
//              tags.count < maxTags else { return }
//        
//        tags.append(trimmedTag)
//        tagsInput = ""
//    }
//    
//    func removeTag(_ tag: String) {
//        tags.removeAll { $0 == tag }
//    }
//    
//    func updateLocationText() {
//        guard let location = locationManager.userLocation else { return }
//        
//        if let previous = previousLocation,
//           location.distance(from: previous) < 100 { return }
//        
//        previousLocation = location
//        
//        let geocoder = CLGeocoder()
//        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
//            guard let self = self,
//                  let placemark = placemarks?.first else { return }
//            
//            var components: [String] = []
//            
//            if let subLocality = placemark.subLocality, !subLocality.isEmpty {
//                components.append(subLocality)
//            }
//            if let locality = placemark.locality, !locality.isEmpty {
//                components.append(locality)
//            }
//            if let area = placemark.administrativeArea, !area.isEmpty {
//                components.append(area)
//            }
//            
//            DispatchQueue.main.async {
//                self.userLocationText = components.joined(separator: ", ")
//            }
//        }
//    }
//}
//
//// MARK: - Main View
//struct PostInputView: View {
//    @StateObject private var viewModel = PostInputViewModel()
//    @Binding var isPresented: Bool
//    @Binding var selectedTab: Int
//    @Environment(\.dismiss) var dismiss
//    @FocusState private var isTextFieldFocused: Bool
//    
//    @State private var isShowingImagePicker = false
//    @State private var showingPicker = false
//    
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                LazyVStack(alignment: .leading, spacing: 12) {
//                    // 图片选择部分
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("添加图片 (最多6张)")
//                            .font(.headline)
//                            .padding(.horizontal)
//                        
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 10) {
//                                ForEach(viewModel.selectedImages.indices, id: \.self) { index in
//                                    ImageTile(
//                                        image: viewModel.selectedImages[index],
//                                        onDelete: {
//                                            viewModel.selectedImages.remove(at: index)
//                                        }
//                                    )
//                                }
//                                
//                                if viewModel.selectedImages.count < 6 {
//                                    AddImageButton(action: { isShowingImagePicker = true })
//                                }
//                            }
//                            .padding(.horizontal)
//                        }
//                    }
//                    
//                    // 位置部分
//                    LocationSection(
//                        locationText: viewModel.userLocationText,
//                        showingPicker: $showingPicker
//                    )
//                    
//                    // 时间选择
//                    TimeSelectionView(
//                        selectedIndex: $viewModel.selectedTimeIndex,
//                        times: viewModel.times
//                    )
//                    
//                    // 标题输入
//                    InputSection(
//                        title: "标题",
//                        text: $viewModel.titleText,
//                        placeholder: "请输入标题"
//                    )
//                    
//                    // 标签部分
//                    TagsView(
//                        tags: $viewModel.tags,
//                        tagsInput: $viewModel.tagsInput,
//                        maxTags: viewModel.maxTags,
//                        onAddTag: viewModel.addTag,
//                        onRemoveTag: viewModel.removeTag
//                    )
//                    
//                    // 正文输入
//                    ContentInputView(text: $viewModel.bodyText)
//                }
//                .padding(.bottom, viewModel.keyboardHeight)
//            }
//            .onAppear {
//                setupView()
//            }
//            .onDisappear {
//                NotificationCenter.default.removeObserver(self)
//            }
//            .sheet(isPresented: $isShowingImagePicker) {
//                MultiImagePicker(images: $viewModel.selectedImages)
//            }
//            .navigationBarItems(
//                leading: dismissButton,
//                trailing: publishButton
//            )
//        }
//    }
//    
//    private var dismissButton: some View {
//        Button(action: {
//            dismiss()
//            selectedTab = 0
//        }) {
//            Image(systemName: "xmark")
//                .font(.title2)
//                .foregroundColor(.black)
//        }
//    }
//    
//    private var publishButton: some View {
//        Button(action: { viewModel.showSecondView = true }) {
//            Text("发布")
//                .font(.system(size: 12, weight: .medium))
//                .padding(.horizontal, 16)
//                .padding(.vertical, 6)
//                .foregroundColor(.white)
//                .background(Color.black)
//                .cornerRadius(25)
//        }
//    }
//    
//    private func setupView() {
//        viewModel.updateLocationText()
//        setupKeyboardObservers()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            isTextFieldFocused = true
//        }
//    }
//    
//    private func setupKeyboardObservers() {
//        NotificationCenter.default.addObserver(
//            forName: UIResponder.keyboardWillShowNotification,
//            object: nil,
//            queue: .main
//        ) { [weak viewModel] notification in
//            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
//            withAnimation {
//                viewModel?.keyboardHeight = keyboardFrame.height - 10
//            }
//        }
//        
//        NotificationCenter.default.addObserver(
//            forName: UIResponder.keyboardWillHideNotification,
//            object: nil,
//            queue: .main
//        ) { [weak viewModel] _ in
//            withAnimation {
//                viewModel?.keyboardHeight = 0
//            }
//        }
//    }
//}
//
//// MARK: - Supporting Views
//struct ImageTile: View {
//    let image: UIImage
//    let onDelete: () -> Void
//    
//    var body: some View {
//        ZStack(alignment: .topTrailing) {
//            Image(uiImage: image)
//                .resizable()
//                .scaledToFill()
//                .frame(width: 100, height: 100)
//                .cornerRadius(8)
//            
//            Button(action: onDelete) {
//                Image(systemName: "xmark.circle.fill")
//                    .foregroundColor(.white)
//                    .background(Circle().fill(Color.red).frame(width: 24, height: 24))
//                    .shadow(radius: 2)
//            }
//            .padding(5)
//        }
//    }
//}
//
//struct AddImageButton: View {
//    let action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            ZStack {
//                RoundedRectangle(cornerRadius: 8)
//                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
//                    .frame(width: 100, height: 100)
//                    .foregroundColor(.black)
//                Image(systemName: "plus")
//                    .font(.title)
//                    .foregroundColor(.gray)
//            }
//        }
//    }
//}
//
//struct LocationSection: View {
//    let locationText: String
//    @Binding var showingPicker: Bool
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("位置")
//                .font(.headline)
//                .padding(.horizontal)
//            
//            HStack(spacing: 2) {
//                if !locationText.isEmpty {
//                    Image(systemName: "mappin.and.ellipse")
//                        .foregroundColor(.blue)
//                }
//                
//                Text(locationText.isEmpty ? "获取位置中..." : locationText)
//                    .font(.system(size: 14))
//                    .padding(.vertical, 6)
//                
//                Spacer()
//                
//                Button("更换位置") {
//                    showingPicker = true
//                }
//                .foregroundColor(.blue)
//            }
//            .padding(.horizontal)
//        }
//    }
//}
//
//struct TimeSelectionView: View {
//    @Binding var selectedIndex: Int
//    let times: [String]
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            HStack {
//                Text("有效时长(可续期)")
//                    .font(.headline)
//                    .padding(.horizontal)
//                
//                Picker("", selection: $selectedIndex) {
//                    ForEach(times.indices, id: \.self) { index in
//                        Text(times[index]).tag(index)
//                    }
//                }
//                .pickerStyle(SegmentedPickerStyle())
//                .padding(.horizontal)
//            }
//        }
//    }
//}
//
//struct InputSection: View {
//    let title: String
//    @Binding var text: String
//    let placeholder: String
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(title)
//                .font(.headline)
//                .padding(.horizontal)
//            
//            TextField(placeholder, text: $text)
//                .padding(.vertical, 6)
//                .padding(.horizontal)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8)
//                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
//                        .foregroundColor(.black)
//                )
//                .padding(.horizontal)
//        }
//    }
//}
//
//struct TagsView: View {
//    @Binding var tags: [String]
//    @Binding var tagsInput: String
//    let maxTags: Int
//    let onAddTag: () -> Void
//    let onRemoveTag: (String) -> Void
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            if !tags.isEmpty {
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack {
//                        ForEach(tags, id: \.self) { tag in
//                            TagView(tag: tag, onRemove: { onRemoveTag(tag) })
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//            }
//            
//            if tags.count < maxTags {
//                TextField("添加标签", text: $tagsInput, onCommit: {
//                    onAddTag()
//                    // 确保输入框被清空
//                    DispatchQueue.main.async {
//                        tagsInput = ""
//                    }
//                })
//                .autocapitalization(.none) // 禁用自动大写
//                .disableAutocorrection(true) // 禁用自动更正
//                .padding(.vertical, 6)
//                .padding(.horizontal)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8)
//                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
//                        .foregroundColor(.black)
//                )
//                .padding(.horizontal)
//            }
//        }
//    }
//}
//
//struct TagView: View {
//    let tag: String
//    let onRemove: () -> Void
//    
//    var body: some View {
//        HStack(spacing: 8) {
//            Text("#\(tag)")
//                .foregroundColor(.black)
//                .padding(.vertical, 4)
//                .padding(.horizontal, 8)
//                .background(Color.blue.opacity(0.2))
//                .cornerRadius(8)
//            
//            Button(action: onRemove) {
//                Image(systemName: "xmark.circle.fill")
//                    .foregroundColor(.red)
//            }
//        }
//        .padding(.horizontal, 4)
//    }
//}
//
//struct ContentInputView: View {
//    @Binding var text: String
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("正文")
//                .font(.headline)
//                .padding(.horizontal)
//            
//            TextEditor(text: $text)
//                .padding(.vertical, 8)
//                .frame(minHeight: 320)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8)
//                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
//                        .foregroundColor(.black)
//                )
//                .padding(.horizontal)
//        }
//    }
//}
//
//// MARK: - Image Picker
//struct MultiImagePicker: UIViewControllerRepresentable {
//    @Binding var images: [UIImage]
//    
//    func makeUIViewController(context: Context) -> PHPickerViewController {
//        var config = PHPickerConfiguration()
//        config.filter = .images
//        config.selectionLimit = 6 - images.count
//        let picker = PHPickerViewController(configuration: config)
//        picker.delegate = context.coordinator
//        return picker
//    }
//    
//    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, PHPickerViewControllerDelegate {
//        var parent: MultiImagePicker
//        
//        init(_ parent: MultiImagePicker) {
//            self.parent = parent
//        }
//        
//        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//            picker.dismiss(animated: true)
//            
//            for result in results {
//                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
//                    result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
//                        if let uiImage = image as? UIImage {
//                            DispatchQueue.main.async {
//                                self?.parent.images.append(uiImage)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Preview
//struct PostInputView_Previews: PreviewProvider {
//    static var previews: some View {
//        PostInputView(
//            isPresented: .constant(true),
//            selectedTab: .constant(0)
//        )
//    }
//}
