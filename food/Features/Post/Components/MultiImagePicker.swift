import SwiftUI
import PhotosUI

struct MultiImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    var completion: ([UIImage]) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        config.selection = .ordered
        // 根据当前已有图片数量计算剩余可选数量
        let remainingCount = 6 - images.count
        config.selectionLimit = max(0, remainingCount)
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: MultiImagePicker
        private var loadedImages: [(Int, UIImage)] = []
        private let loadQueue = DispatchQueue(label: "com.app.imageLoading")
        private var retainCycle: Coordinator?
        
        init(_ parent: MultiImagePicker) {
            self.parent = parent
            super.init()
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            print("Started picking with \(results.count) results")
            print("Current images count: \(parent.images.count)")
            picker.dismiss(animated: true)
            
            guard !results.isEmpty else {
                print("No images selected")
                return
            }
            
            retainCycle = self
            
            let group = DispatchGroup()
            loadedImages.removeAll()
            
            for (index, result) in results.enumerated() {
                group.enter()
                
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                    defer { group.leave() }
                    
                    if let error = error {
                        print("Error loading image \(index): \(error)")
                        return
                    }
                    
                    guard let image = object as? UIImage else {
                        print("Failed to load image \(index)")
                        return
                    }
                    
                    print("Successfully loaded image \(index)")
                    
                    self?.loadQueue.sync {
                        self?.loadedImages.append((index, image))
                    }
                }
            }
            
            group.notify(queue: .main) { [weak self] in
                guard let self = self else {
                    print("Coordinator was deallocated")
                    return
                }
                
                print("Processing final results...")
                let sortedImages = self.loadedImages.sorted(by: { $0.0 < $1.0 }).map({ $0.1 })
                print("New loaded images count: \(sortedImages.count)")
                
                if !sortedImages.isEmpty {
                    // 合并现有图片和新选择的图片
                    let combinedImages = parent.images + sortedImages
                    // 确保总数不超过6张
                    let finalImages = Array(combinedImages.prefix(6))
                    print("Final combined images count: \(finalImages.count)")
                    self.parent.completion(finalImages)
                }
                
                self.retainCycle = nil
                print("Image loading completed and retain cycle broken")
            }
        }
    }
}
