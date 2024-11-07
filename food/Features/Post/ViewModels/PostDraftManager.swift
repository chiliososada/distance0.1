//
//  DraftImageManager.swift
//  food
//
//  Created by toyousoft on 2024/11/07.
//

import UIKit


class DraftImageManager {
   
    static let shared = DraftImageManager()
    
  
    private let fileManager = FileManager.default
    private let draftImagesDirectory = "DraftImages"
    
   
    private init() {
        createDraftImagesDirectoryIfNeeded()
    }
    
 
    private var draftImagesURL: URL? {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to get documents directory")
            return nil
        }
        return documentsDirectory.appendingPathComponent(draftImagesDirectory)
    }
    
    private func createDraftImagesDirectoryIfNeeded() {
        guard let draftImagesURL = draftImagesURL else {
            print("Failed to get draft images URL")
            return
        }
        
        if !fileManager.fileExists(atPath: draftImagesURL.path) {
            do {
                try fileManager.createDirectory(at: draftImagesURL,
                                             withIntermediateDirectories: true)
            } catch {
                print("Failed to create draft images directory: \(error)")
            }
        }
    }
    
 
    func saveImage(_ image: UIImage) -> String? {
        guard let draftImagesURL = draftImagesURL else {
            print("Failed to get draft images URL")
            return nil
        }
        
        let identifier = UUID().uuidString
        let imageURL = draftImagesURL.appendingPathComponent(identifier)
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to data")
            return nil
        }
        
        do {
            try imageData.write(to: imageURL)
            return identifier
        } catch {
            print("Failed to save image: \(error)")
            return nil
        }
    }
    
    func loadImage(identifier: String) -> UIImage? {
        guard let draftImagesURL = draftImagesURL else {
            print("Failed to get draft images URL")
            return nil
        }
        
        let imageURL = draftImagesURL.appendingPathComponent(identifier)
        
        do {
            let imageData = try Data(contentsOf: imageURL)
            guard let image = UIImage(data: imageData) else {
                print("Failed to create image from data")
                return nil
            }
            return image
        } catch {
            print("Failed to load image: \(error)")
            return nil
        }
    }
    
  
    func clearAllDraftImages() {
        guard let draftImagesURL = draftImagesURL else {
            print("Failed to get draft images URL")
            return
        }
        
        do {
            try fileManager.removeItem(at: draftImagesURL)
            createDraftImagesDirectoryIfNeeded()
        } catch {
            print("Failed to clear draft images: \(error)")
        }
    }
    
  
    func deleteImage(identifier: String) {
        guard let draftImagesURL = draftImagesURL else {
            print("Failed to get draft images URL")
            return
        }
        
        let imageURL = draftImagesURL.appendingPathComponent(identifier)
        
        do {
            try fileManager.removeItem(at: imageURL)
        } catch {
            print("Failed to delete image: \(error)")
        }
    }
    
    
    func deleteImages(identifiers: [String]) {
        identifiers.forEach { deleteImage(identifier: $0) }
    }
    
  
    func getAllImageIdentifiers() -> [String] {
        guard let draftImagesURL = draftImagesURL else {
            return []
        }
        
        do {
            return try fileManager.contentsOfDirectory(atPath: draftImagesURL.path)
        } catch {
            print("Failed to get image identifiers: \(error)")
            return []
        }
    }
    

    func imageExists(identifier: String) -> Bool {
        guard let draftImagesURL = draftImagesURL else {
            return false
        }
        
        let imageURL = draftImagesURL.appendingPathComponent(identifier)
        return fileManager.fileExists(atPath: imageURL.path)
    }
    
  
    func getDraftImagesSize() -> Int64 {
        guard let draftImagesURL = draftImagesURL else {
            return 0
        }
        
        do {
            let resourceValues = try draftImagesURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey])
            return Int64(resourceValues.totalFileAllocatedSize ?? 0)
        } catch {
            print("Failed to get directory size: \(error)")
            return 0
        }
    }
}
