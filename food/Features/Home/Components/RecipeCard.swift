//
//  RecipeCard.swift
//  food
//
//  Created by toyousoft on 2024/11/03.
//

import SwiftUI


// MARK: - RecipeCard
struct RecipeCard: View {
    let recipe: RecommendedRecipe
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
   
    private var imageItems: [ImageItem] {
          recipe.imageNames.map { imageName in
              // 获取图片实际尺寸并计算比例
              if let uiImage = UIImage(named: imageName) {
                  let aspectRatio = uiImage.size.width / uiImage.size.height
                  return ImageItem(imageName: imageName, aspectRatio: aspectRatio)
              } else {
                  // 如果无法加载图片，默认使用 1:1 比例
                  return ImageItem(imageName: imageName, aspectRatio: 1.0)
              }
          }
      }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author Header
            AuthorHeader(recipe: recipe)
            
            // Title
            Text(recipe.title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // Image Gallery - 使用原来的 ImageGalleryView
            ImageGalleryView(images: imageItems)
            
            // Tags
            TagsRow(tags: recipe.tags)
            
            // Footer
            CardFooter(recipe: recipe)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .frame(maxWidth: horizontalSizeClass == .compact ? 350 : .infinity)
    }
}
