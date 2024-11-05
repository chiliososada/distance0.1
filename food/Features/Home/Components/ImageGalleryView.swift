//
//  ImageGalleryView.swift
//  food
//
//  Created by toyousoft on 2024/11/05.
//

import SwiftUI

struct ImageItem {
    let imageName: String
    let aspectRatio: CGFloat // 宽高比 (width/height)
    
    var isPortrait: Bool { aspectRatio < 1 }
    var isLandscape: Bool { aspectRatio > 1 }
    var isSquare: Bool { abs(aspectRatio - 1.0) < 0.1 } // 允许有小误差
}

struct ImageGalleryView: View {
    let images: [ImageItem]
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    private let spacing: CGFloat = 5
    private let cornerRadius: CGFloat = 8
    private let maxHeightRatio: CGFloat = 0.75 // 最大高度比例
    
    private var cardWidth: CGFloat {
        horizontalSizeClass == .compact ? 350.0 : UIScreen.main.bounds.width - 32
    }
    
    // 基础图片修饰符 - 改用 .fit 来确保完整显示
    private func baseImageModifier(_ image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
    
    // 计算图片适合的尺寸
    private func calculateImageSize(_ image: ImageItem, maxWidth: CGFloat) -> CGSize {
        let aspectRatio = max(image.aspectRatio, 0.1)
        let naturalHeight = maxWidth / aspectRatio
        let maxHeight = cardWidth * maxHeightRatio
        let height = min(naturalHeight, maxHeight)
        return CGSize(width: maxWidth, height: height)
    }
    
    private func singleImageView(_ image: ImageItem) -> some View {
        let screenWidth = UIScreen.main.bounds.width
        let aspectRatio = image.aspectRatio
        let height = screenWidth / aspectRatio // 根据宽度和图片比例计算实际需要的高度
        
        return baseImageModifier(Image(image.imageName))
            .frame(width: screenWidth, height: height) // 使用计算出的高度
    }
    // 双图布局
    private func twoImagesView(_ images: [ImageItem]) -> some View {
        let itemWidth = (cardWidth - spacing) / 2
        return HStack(spacing: spacing) {
            ForEach(0..<2, id: \.self) { index in
                let image = images[index]
                let size = calculateImageSize(image, maxWidth: itemWidth)
                baseImageModifier(Image(image.imageName))
                    .frame(width: size.width, height: size.height)
            }
        }
    }
    
    // 三图布局
    private func threeImagesView(_ images: [ImageItem]) -> some View {
        let itemWidth = (cardWidth - spacing) / 2
        return VStack(spacing: spacing) {
            // 第一行一张图
            let firstImageSize = calculateImageSize(images[0], maxWidth: cardWidth)
            baseImageModifier(Image(images[0].imageName))
                .frame(width: firstImageSize.width, height: firstImageSize.height)
            
            // 第二行两张图
            HStack(spacing: spacing) {
                ForEach(1...2, id: \.self) { index in
                    let size = calculateImageSize(images[index], maxWidth: itemWidth)
                    baseImageModifier(Image(images[index].imageName))
                        .frame(width: size.width, height: size.height)
                }
            }
        }
    }
    
    // 四图及以上布局
    private func fourAndMoreImagesView(_ images: [ImageItem]) -> some View {
        let spacing: CGFloat = 5
        let itemWidth = (cardWidth - spacing) / 2
        
        return VStack(spacing: spacing) {
            // 第一行两张图
            HStack(spacing: spacing) {
                ForEach(0..<2, id: \.self) { index in
                    let size = calculateImageSize(images[index], maxWidth: itemWidth)
                    baseImageModifier(Image(images[index].imageName))
                        .frame(width: size.width, height: size.height)
                }
            }
            
            // 第二行两张图，最后一张可能显示剩余数量
            HStack(spacing: spacing) {
                let size3 = calculateImageSize(images[2], maxWidth: itemWidth)
                baseImageModifier(Image(images[2].imageName))
                    .frame(width: size3.width, height: size3.height)
                
                ZStack {
                    let size4 = calculateImageSize(images[3], maxWidth: itemWidth)
                    baseImageModifier(Image(images[3].imageName))
                        .frame(width: size4.width, height: size4.height)
                    
                    if images.count > 4 {
                        Rectangle()
                            .fill(Color.black.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        
                        Text("+\(images.count - 4)")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    var body: some View {
        Group {
            switch images.count {
            case 1:
                singleImageView(images[0])
            case 2:
                twoImagesView(images)
            case 3:
                threeImagesView(images)
            default:
                fourAndMoreImagesView(images)
            }
        }
        .frame(width: cardWidth)
    }
}
