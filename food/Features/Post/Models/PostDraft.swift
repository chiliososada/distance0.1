//
//  PostDraft.swift
//  food
//
//  Created by toyousoft on 2024/11/06.
//
import Foundation

// 更新草稿结构
  struct BlogDraft: Codable {
      let title: String
      let content: String
      let location: String
      let tags: [String]
      let imageNames: [String]
      let selectedDuration: String
      let chatRoomEnabled: Bool
      let announcement: String
  }
