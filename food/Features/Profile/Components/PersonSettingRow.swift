//
//  PersonSettingRow.swift
//  food
//
//  Created by toyousoft on 2024/11/12.
//

import SwiftUI

// MARK: - 设置项组件
struct PersonSettingRow<Content: View>: View {
    let title: String
    let titleColor: Color
    let action: (() -> Void)?
    let trailing: Content
    
    init(
        title: String,
        titleColor: Color = .primary,
        action: (() -> Void)? = nil,
        @ViewBuilder trailing: () -> Content
    ) {
        self.title = title
        self.titleColor = titleColor
        self.action = action
        self.trailing = trailing()
    }
    
    var body: some View {
        if let action = action {
            Button(action: action) {
                rowContent
            }
        } else {
            rowContent
        }
    }
    
    private var rowContent: some View {
        HStack {
            Text(title)
                .foregroundColor(titleColor)
            Spacer()
            trailing
        }
        .padding(.vertical, 10)
    }
}
