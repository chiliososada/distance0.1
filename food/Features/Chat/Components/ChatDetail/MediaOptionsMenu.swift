import SwiftUI
import PhotosUI
import UIKit

// MARK: - Media Option Models
import SwiftUI
import PhotosUI
import UIKit

// MARK: - Media Option Models
enum MediaOption: Identifiable {
    case camera
    case photoLibrary
    
    var id: String { title }
    
    // 更新图标样式
    var icon: String {
        switch self {
        case .camera: return "camera.aperture"  // 使用更精致的相机图标
        case .photoLibrary: return "photo.stack.fill"  // 使用层叠效果的照片图标
        }
    }
    
    var title: String {
        switch self {
        case .camera: return "相机"
        case .photoLibrary: return "相册"
        }
    }
    
    // 使用渐变色
    var gradientColors: [Color] {
        switch self {
        case .camera:
            return [
                Color(red: 0.32, green: 0.46, blue: 0.98), // 蓝色
                Color(red: 0.44, green: 0.38, blue: 0.92)  // 紫色
            ]
        case .photoLibrary:
            return [
                Color(red: 0.90, green: 0.36, blue: 0.51), // 粉色
                Color(red: 0.93, green: 0.23, blue: 0.36)  // 红色
            ]
        }
    }
    
    // 背景装饰图标
    var decorationIcon: String {
        switch self {
        case .camera: return "circle.grid.cross.fill"
        case .photoLibrary: return "square.grid.3x3.fill"
        }
    }
}

enum MediaResult {
    case capturedImage(UIImage)
    case selectedImages([UIImage])
}

// MARK: - Media Options Menu
struct MediaOptionsMenu: View {
    @Binding var isPresented: Bool
    @State private var showChatImagePicker = false
    @State private var showCamera = false
    let onSelect: (MediaResult) -> Void
    
    private let options: [MediaOption] = [
        .camera,
        .photoLibrary
    ]
    
    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 20) {
                ForEach(options) { option in
                    MediaOptionButton(option: option) {
                        handleOptionTap(option)
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background(Color(.systemBackground))
        }
        .frame(height: 120)
        .background(Color(.systemBackground))
        .transition(.move(edge: .bottom))
        .sheet(isPresented: $showChatImagePicker) {
            PhotoPicker(isPresented: $showChatImagePicker) { images in
                if !images.isEmpty {
                    onSelect(.selectedImages(images))
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraView { image in
                if let image = image {
                    onSelect(.capturedImage(image))
                }
            }
        }
    }
    
    private func handleOptionTap(_ option: MediaOption) {
        switch option {
        case .camera:
            showCamera = true
        case .photoLibrary:
            showChatImagePicker = true
        }
    }
}

// MARK: - Button View
struct MediaOptionButton: View {
    let option: MediaOption
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // 主图标容器
                ZStack {
                    // 渐变背景
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: option.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .shadow(
                            color: option.gradientColors[0].opacity(0.5),
                            radius: isPressed ? 4 : 8,
                            x: 0,
                            y: isPressed ? 2 : 4
                        )
                    
                    // 装饰背景图标
                    Image(systemName: option.decorationIcon)
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.2))
                        .offset(x: 1, y: 1)
                    
                    // 主图标
                    Image(systemName: option.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                }
                
                // 标题
                Text(option.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .pressEvents {
            withAnimation {
                isPressed = true
            }
        } onRelease: {
            withAnimation {
                isPressed = false
            }
        }
    }
}

// MARK: - Photo Picker
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let completion: ([UIImage]) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 6
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        
        init(parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard !results.isEmpty else {
                parent.isPresented = false
                return
            }
            
            let dispatchGroup = DispatchGroup()
            var images: [UIImage] = []
            
            for result in results {
                dispatchGroup.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    defer { dispatchGroup.leave() }
                    if let image = object as? UIImage {
                        images.append(image)
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.parent.completion(images)
                self.parent.isPresented = false
            }
        }
    }
}

// MARK: - Camera View
struct CameraView: UIViewControllerRepresentable {
    let completion: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.completion(image)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.completion(nil)
            picker.dismiss(animated: true)
        }
    }
}

// 添加按压事件检测
extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    onPress()
                }
                .onEnded { _ in
                    onRelease()
                }
        )
    }
}
