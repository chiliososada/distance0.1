//
//  HomeTabView.swift
//  food
//
//  Created by toyousoft on 2024/11/24.
//

import SwiftUI
import Combine

// MARK: - View
struct HomeTabView: View {
    @StateObject private var viewModel = HomeTabViewModel() // 改为本地 StateObject
    @EnvironmentObject private var navigationManager: AppNavigationManager
    var onMenuTap: () -> Void  // 改为 var
    
    // 添加显式构造器
    init(onMenuTap: @escaping () -> Void) {
        self.onMenuTap = onMenuTap
    }
    
    var body: some View {
        VStack(spacing: 1) {
            navigationBar
            
            VStack(spacing: 1) {
                SearchAndFilterView(search: $viewModel.search)
                    .padding(.vertical, 2)
                
                postsContent
            }
        }
        .background(Color.white)
    }
    
    private var navigationBar: some View {
        CustomNavigationBar(
            userLocationText: viewModel.userLocationText,
            onMenuTap: onMenuTap
        )
    }
    
    private var postsContent: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.posts) { post in
                    LocationPostButton(post: post) {
                        navigationManager.navigate(to: .postDetail(post: post))
                    }
                    .id(post.id)
                }
            }
            .padding()
        }
    }
}

// MARK: - Supporting Views
struct CustomNavigationBar: View {
    let userLocationText: String
    let onMenuTap: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onMenuTap) {
                Image(uiImage: #imageLiteral(resourceName: "menu"))
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Button(action: {
                print("Location button tapped")
            }) {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                    Text(userLocationText)
                        .font(.caption2)
                        .lineLimit(1)
                }
                .foregroundColor(.black)
            }
        }
        .padding(.horizontal)
        .frame(height: 44)
        .background(Color.white)
    }
}

