import UIKit

class DraftImageManager {
    static let shared = DraftImageManager()
    private let fileManager = FileManager.default
    private let processingQueue = DispatchQueue(label: "com.app.imageProcessing", qos: .userInitiated)
    private let draftImagesDirectory = "DraftImages"
    private var cachedImages = NSCache<NSString, UIImage>()
    private let lock = NSLock()
    
    // 设置缓存限制
    init() {
        createDraftImagesDirectoryIfNeeded()
        cachedImages.countLimit = 10 // 限制缓存图片数量
        cachedImages.totalCostLimit = 50 * 1024 * 1024 // 限制缓存大小为50MB
    }
    
    private var draftImagesURL: URL? {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent(draftImagesDirectory)
    }
    
    private func createDraftImagesDirectoryIfNeeded() {
        guard let draftImagesURL = draftImagesURL else { return }
        
        if !fileManager.fileExists(atPath: draftImagesURL.path) {
            try? fileManager.createDirectory(at: draftImagesURL,
                                          withIntermediateDirectories: true,
                                          attributes: nil)
        }
    }
    
    func saveImage(_ image: UIImage) -> String? {
        return autoreleasepool {
            guard let draftImagesURL = draftImagesURL else { return nil }
            
            let identifier = UUID().uuidString
            let imageURL = draftImagesURL.appendingPathComponent(identifier)
            
            // 处理图片
            guard let processedImage = processImage(image),
                  let imageData = processedImage.jpegData(compressionQuality: 0.7) else {
                return nil
            }
            
            do {
                try imageData.write(to: imageURL)
                
                // 安全地更新缓存
                lock.lock()
                if let savedImage = UIImage(data: imageData) {
                    cachedImages.setObject(savedImage, forKey: identifier as NSString)
                }
                lock.unlock()
                
                return identifier
            } catch {
                print("Failed to save image: \(error)")
                return nil
            }
        }
    }
    
    func loadImage(identifier: String) -> UIImage? {
        // 检查缓存
        lock.lock()
        if let cachedImage = cachedImages.object(forKey: identifier as NSString) {
            lock.unlock()
            return cachedImage
        }
        lock.unlock()
        
        // 从文件加载
        guard let draftImagesURL = draftImagesURL else { return nil }
        let imageURL = draftImagesURL.appendingPathComponent(identifier)
        
        return autoreleasepool {
            guard let imageData = try? Data(contentsOf: imageURL),
                  let image = UIImage(data: imageData) else {
                return nil
            }
            
            // 更新缓存
            lock.lock()
            cachedImages.setObject(image, forKey: identifier as NSString)
            lock.unlock()
            
            return image
        }
    }
    
    private func processImage(_ image: UIImage) -> UIImage? {
        return autoreleasepool {
            let maxSize: CGFloat = 1024
            let size = image.size
            
            // 计算缩放比例
            let scale = min(maxSize / max(size.width, size.height), 1.0)
            
            if scale >= 1.0 {
                return fixOrientation(image)
            }
            
            let newSize = CGSize(
                width: size.width * scale,
                height: size.height * scale
            )
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            defer { UIGraphicsEndImageContext() }
            
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            
            return fixOrientation(resizedImage ?? image)
        }
    }
    
    private func fixOrientation(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }
        
        return autoreleasepool {
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            defer { UIGraphicsEndImageContext() }
            
            image.draw(in: CGRect(origin: .zero, size: image.size))
            return UIGraphicsGetImageFromCurrentImageContext() ?? image
        }
    }
    
    func deleteImage(identifier: String) {
        guard let draftImagesURL = draftImagesURL else { return }
        let imageURL = draftImagesURL.appendingPathComponent(identifier)
        
        lock.lock()
        cachedImages.removeObject(forKey: identifier as NSString)
        lock.unlock()
        
        try? fileManager.removeItem(at: imageURL)
    }
    
    func imageExists(identifier: String) -> Bool {
        lock.lock()
        if cachedImages.object(forKey: identifier as NSString) != nil {
            lock.unlock()
            return true
        }
        lock.unlock()
        
        guard let draftImagesURL = draftImagesURL else { return false }
        let imageURL = draftImagesURL.appendingPathComponent(identifier)
        return fileManager.fileExists(atPath: imageURL.path)
    }
}
