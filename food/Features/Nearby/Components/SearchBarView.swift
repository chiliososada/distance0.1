//
//  SearchBarView.swift
//  food
//
//  Created by toyousoft on 2024/11/04.
//

import SwiftUI


struct SearchBarView: View {
    @Binding var search: String
    @Binding var showFilterView: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("请输入要查找的话题，标签等...", text: $search)
                    .padding(.vertical, 2)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.black)
                    .accentColor(.gray)
            }
            .padding(8)
            .background(Color(UIColor.white))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
            
            Button(action: {
                showFilterView.toggle()
            }) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.black)
                    .padding(8)
                    .background(Color(UIColor.white))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal)
    }
}
