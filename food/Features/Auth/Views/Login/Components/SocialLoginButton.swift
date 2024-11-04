//
//  SocialLoginButton.swift
//  food
//
//  Created by toyousoft on 2024/11/04.
//

import SwiftUI

// MARK: - Social Login Button
struct SocialLoginButton: View {
    let icon: String
    let title: String
    let isSystemImage: Bool
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isSystemImage {
                    Image(systemName: icon)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(iconColor)
                } else {
                    Image(icon)
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }
}
