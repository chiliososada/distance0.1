//
//  PostDraftManager.swift
//  food
//
//  Created by toyousoft on 2024/11/06.
//

import Foundation
import UIKit

class PostDraftManager {
    static let shared = PostDraftManager()
    private let defaults = UserDefaults.standard
    private let draftKey = "post_draft"
    
    private init() {}
    
    func saveDraft(_ post: PostModel) {
        let draftData = PostDraft(
            title: post.title,
            content: post.content,
            location: post.location,
            tags: post.tags,
            imageData: post.images.compactMap { $0.jpegData(compressionQuality: 0.7) }
        )
        
        if let encoded = try? JSONEncoder().encode(draftData) {
            defaults.set(encoded, forKey: draftKey)
        }
    }
    
    func loadDraft() -> PostModel? {
        guard let data = defaults.data(forKey: draftKey),
              let draftData = try? JSONDecoder().decode(PostDraft.self, from: data)
        else { return nil }
        
        let images = draftData.imageData.compactMap { data in
            UIImage(data: data)
        }
        
        return PostModel(
            title: draftData.title,
            content: draftData.content,
            location: draftData.location,
            tags: draftData.tags,
            images: images
        )
    }
    
    func clearDraft() {
        defaults.removeObject(forKey: draftKey)
    }
    
    func hasDraft() -> Bool {
        return defaults.data(forKey: draftKey) != nil
    }
}
