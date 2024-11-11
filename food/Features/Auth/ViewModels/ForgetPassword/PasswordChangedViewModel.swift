//
//  PasswordChangedViewModel.swift
//  food
//
//  Created by toyousoft on 2024/11/05.
//
import SwiftUI

class PasswordChangedViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    func performAutoLogin() async throws -> Bool {
      
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
    
        return true
    }
}
