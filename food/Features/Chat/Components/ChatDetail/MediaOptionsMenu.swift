import SwiftUI
import PhotosUI

// MARK: - Media Option Models
enum MediaOption: Identifiable {
    case camera
    case photoLibrary
    case sticker
    case audio
    case more
    
    var id: String { title }
    
    var icon: String {
        switch self {
        case .camera: return "camera.fill"
        case .photoLibrary: return "photo.fill"
        case .sticker: return "moonphase.last.quarter"
        case .audio: return "waveform"
        case .more: return "chevron.down"
        }
    }
    
    var title: String {
        switch self {
        case .camera: return "相机"
        case .photoLibrary: return "照片"
        case .sticker: return "贴纸"
        case .audio: return "音频"
        case .more: return "更多"
        }
    }
    
    var color: Color {
        switch self {
        case .camera: return Color(.systemGray2)
        case .photoLibrary: return Color(.systemGray2)
        case .sticker: return .purple.opacity(0.8)
        case .audio: return .orange.opacity(0.8)
        case .more: return Color(.systemBlue)
        }
    }
}

enum MediaResult {
    case capturedImage(UIImage)
    case selectedImages([UIImage])
    case sticker
    case audio
    case more
}

// MARK: - Media Options Menu
struct MediaOptionsMenu: View {
    @Binding var isPresented: Bool
    @State private var showChatImagePicker = false
    @State private var showCamera = false
    let onSelect: (MediaResult) -> Void
    
    private let options: [MediaOption] = [
        .camera,
        .photoLibrary,
        .sticker,
        .audio,
        .more
    ]
    
    var body: some View {
        // 选项菜单
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
        .frame(height: 120) // 设置固定高度
        .background(Color(.systemBackground))
        .transition(.move(edge: .bottom))
        .sheet(isPresented: $showChatImagePicker) {
            ChatImagePicker { images in
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
        case .sticker:
            onSelect(.sticker)
        case .audio:
            onSelect(.audio)
        case .more:
            onSelect(.more)
        }
    }
}
// MARK: - Chat Image Picker
struct ChatImagePicker: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItems: [PhotosPickerItem] = []
    let completion: ([UIImage]) -> Void
    
    var body: some View {
        NavigationView {
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 9,
                matching: .images,
                preferredItemEncoding: .automatic
            ) {
                Color.clear
            }
            .navigationTitle("选择图片")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: selectedItems) { newItems in
            Task {
                var images: [UIImage] = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        images.append(image)
                    }
                }
                
                DispatchQueue.main.async {
                    completion(images)
                    dismiss()
                }
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

// MARK: - Media Option Button
struct MediaOptionButton: View {
    let option: MediaOption
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(option.color)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: option.icon)
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    )
                
                Text(option.title)
                    .font(.system(size: 12))
                    .foregroundColor(.primary)
            }
        }
    }
}

// MARK: - Preview
struct MediaOptionsMenu_Previews: PreviewProvider {
    static var previews: some View {
        MediaOptionsMenu(
            isPresented: .constant(true),
            onSelect: { result in
                print("Selected: \(result)")
            }
        )
    }
}
