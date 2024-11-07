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
    
    func saveDraft(_ post: LocationPost) {
        let draftData = PostDraft(
            title: post.title ?? "",
            content: post.content,
            location: post.locationName,
            tags: post.tags,
            imageNames: post.imageNames
        )
        
        if let encoded = try? JSONEncoder().encode(draftData) {
            defaults.set(encoded, forKey: draftKey)
        }
    }
    
    func loadDraft() -> LocationPost? {
        guard let data = defaults.data(forKey: draftKey),
              let draftData = try? JSONDecoder().decode(PostDraft.self, from: data)
        else { return createEmptyPost() }
        
        return LocationPost(
            title: draftData.title,
            content: draftData.content,
            authorName: "当前用户",  // 使用默认值
            locationName: draftData.location,
            latitude: 0,  // 可以在实际发布时更新
            longitude: 0, // 可以在实际发布时更新
            imageNames: draftData.imageNames,
            avatarImage: "default_avatar",  // 使用默认值
            tags: draftData.tags,
            participantsCount: 0,
            postedTime: "",
            remainingDays: "",
            publishDate: "",
            joinedCount: "0",
            isSponsored: false
        )
    }
    
    private func createEmptyPost() -> LocationPost {
        return LocationPost(
            title: "",
            content: "",
            authorName: "当前用户",
            locationName: "",
            latitude: 0,
            longitude: 0,
            imageNames: [],
            avatarImage: "default_avatar",
            tags: [],
            participantsCount: 0,
            postedTime: "",
            remainingDays: "",
            publishDate: "",
            joinedCount: "0",
            isSponsored: false
        )
    }
    
    func clearDraft() {
        defaults.removeObject(forKey: draftKey)
    }
    
    func hasDraft() -> Bool {
        return defaults.data(forKey: draftKey) != nil
    }
}
