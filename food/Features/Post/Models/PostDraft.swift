//
//  PostDraft.swift
//  food
//
//  Created by toyousoft on 2024/11/06.
//
import Foundation

struct PostDraft: Codable {
    let title: String
    let content: String
    let location: String
    let tags: [String]
    let imageData: [Data]
}
