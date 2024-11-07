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
    let imageNames: [String]  // 仅存储图片名称/标识符
}
