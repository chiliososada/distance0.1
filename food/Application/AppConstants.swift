//
//  AppConstants.swift
//  food
//
//  Created by toyousoft on 2024/11/10.
//


import Foundation

enum AppConstants {
    // MARK: - UserDefaults Keys
    enum UserDefaultsKeys {
        static let isLoggedIn = "isLoggedIn"
        static let userProfile = "userProfile"
        static let authToken = "authToken"
        static let pushToken = "pushToken"
        static let lastLoginDate = "lastLoginDate"
    }
    
    // MARK: - Network
    enum Network {
        static let baseURL = "https://api.yourserver.com"
        static let apiVersion = "v1"
        static let timeout: TimeInterval = 30
    }
    
    // MARK: - Cache
    enum Cache {
        static let maxSize: Int = 50 * 1024 * 1024  // 50MB
        static let expirationDays: Int = 7
    }
    
    // MARK: - UI
    enum UI {
        static let animationDuration: Double = 0.3
        static let cornerRadius: CGFloat = 8.0
        static let defaultPadding: CGFloat = 16.0
    }
    
    // MARK: - Validation
    enum Validation {
        static let minPasswordLength = 8
        static let maxUsernameLength = 30
        static let maxBioLength = 200
    }
    
    // MARK: - File System
    enum FileSystem {
        static let maxUploadSize: Int64 = 10 * 1024 * 1024  // 10MB
        static let allowedImageTypes = ["jpg", "jpeg", "png", "heic"]
    }
}
