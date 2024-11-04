//
//  MultiImagePicker.swift
//  food
//
//  Created by toyousoft on 2024/11/04.
//
import SwiftUI
import PhotosUI

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
