//
//  UserProfile.swift
//  food
//
//  Created by toyousoft on 2024/11/03.
//

import Foundation

// MARK: - User Profile Model
struct UserProfile: Codable {
    let userId: String
    let userName: String
    var location: String?
    var bio: String?
    var avatarUrl: String?
   
   
    
    // 统计信息
    struct Stats {
        let participantsCount: String
        let viewedTopicsCount: String
    }
    
    // 个人设置
    struct Settings {
        var nickname: String
        var bio: String
        var idNumber: String
        var gender: String
        var birthDate: Date
    }
    
    // MARK: - Sample Data
    static let sample = UserProfile(
        userId: "user123",
        userName: "liu ziyuan",
        location: "東京都 葛飾区 立石",
        bio: "我是一个专注于前端开发的程序员",
        avatarUrl: "sample1"
    )
    
    static let sampleStats = Stats(
        participantsCount: "1K+",
        viewedTopicsCount: "1M+"
    )
    
    static let sampleSettings = Settings(
        nickname: "东京 it 小白",
        bio: "美妙的生活由此开始~",
        idNumber: "178385",
        gender: "男",
        birthDate: Date()
    )
    
    // MARK: - Helpers
    func formattedJoinDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return "加入日: \(formatter.string(from: Date()))"
    }
}

