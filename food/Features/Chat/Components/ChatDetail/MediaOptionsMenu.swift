import SwiftUI
import PhotosUI
import UIKit

// MARK: - Media Option Models
enum MediaOption: Identifiable {
    case camera
    case photoLibrary
    case audio
    
    var id: String { title }
    
    var icon: String {
        switch self {
        case .camera: return "camera.fill"
        case .photoLibrary: return "photo.fill"
        case .audio: return "waveform"
        }
    }
    
    var title: String {
        switch self {
        case .camera: return "相机"
        case .photoLibrary: return "照片"
        case .audio: return "音频"
        }
    }
    
    var color: Color {
        switch self {
        case .camera: return Color(.systemGray2)
        case .photoLibrary: return Color(.systemGray2)
        case .audio: return .orange.opacity(0.8)
        }
    }
}

enum MediaResult {
    case capturedImage(UIImage)
    case selectedImages([UIImage])
    case audio
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
        .audio
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
        case .audio:
            onSelect(.audio)
        }
    }
}

// MARK: - Button View
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
