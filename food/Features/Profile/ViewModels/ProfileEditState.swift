//
//  ProfileEditState.swift
//  food
//
//  Created by toyousoft on 2024/11/03.
//
//

import SwiftUI

// MARK: - Profile Edit State
final class ProfileEditState: ObservableObject {
    @Published var nickname: String = ""
    @Published var bio: String = ""
    @Published var idNumber: String = ""
    @Published var selectedGender: UserProfile.Gender = .male
    @Published var selectedImage: UIImage?
    @Published var showImagePicker = false
    @Published var showImagePickerOptions = false
    @Published var isShowingDatePicker = false
    @Published var birthDate = Date()
    
    // 使用 Gender 枚举的本地化字符串
    var genderOptions: [String] {
        UserProfile.Gender.allCases.map { $0.localizedString }
    }
    
    // 当前选中性别的本地化字符串
    var selectedGenderString: String {
        selectedGender.localizedString
    }
    
    init(profile: UserProfile? = nil) {
        if let profile = profile {
            nickname = profile.settings.nickname
            bio = profile.settings.bio
            idNumber = profile.settings.idNumber
            selectedGender = profile.settings.gender
            birthDate = profile.settings.birthDate
        } else {
            // 使用默认值初始化
            nickname = "新用户"
            bio = ""
            idNumber = UUID().uuidString
            selectedGender = .male
            birthDate = Date()
        }
    }
    
    // 更新性别选择（从字符串到枚举值）
    func updateGender(with localizedString: String) {
        if let gender = UserProfile.Gender.allCases.first(where: { $0.localizedString == localizedString }) {
            selectedGender = gender
        }
    }
    
    var hasChanges: Bool {
        // 这里需要与当前用户的实际配置文件进行比较
        // 暂时返回true用于测试
        true
    }
}
