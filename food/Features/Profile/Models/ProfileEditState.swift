//
//  ProfileEditState.swift
//  food
//
//  Created by toyousoft on 2024/11/03.
//
import SwiftUI

// MARK: - Profile Edit State
final class ProfileEditState: ObservableObject {
    @Published var nickname: String = UserProfile.sampleSettings.nickname
    @Published var bio: String = UserProfile.sampleSettings.bio
    @Published var idNumber: String = UserProfile.sampleSettings.idNumber
    @Published var selectedGender: String = UserProfile.sampleSettings.gender
    @Published var selectedImage: UIImage?
    @Published var showImagePicker = false
    @Published var showImagePickerOptions = false
    @Published var isShowingDatePicker = false
    @Published var birthDate = UserProfile.sampleSettings.birthDate
    
    let genders = ["男", "女", "其他"]
    
    var hasChanges: Bool {
        nickname != UserProfile.sampleSettings.nickname ||
        bio != UserProfile.sampleSettings.bio ||
        selectedGender != UserProfile.sampleSettings.gender ||
        selectedImage != nil ||
        birthDate != UserProfile.sampleSettings.birthDate
    }
    
    // Add any additional profile editing functionality here
}
