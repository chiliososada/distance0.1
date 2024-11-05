//
//  ImageCarouselContent.swift
//  food
//
//  Created by toyousoft on 2024/11/05.
//
import SwiftUI

struct ImageCarouselContent: View {
    let images: [String]
    @Binding var currentIndex: Int
    
    // 用来存储图片尺寸信息
    private struct ImageDimensions {
        let width: CGFloat
        let height: CGFloat
        let isPortrait: Bool
        let aspectRatio: CGFloat
        
        init(image: UIImage) {
            self.width = image.size.width
            self.height = image.size.height
            self.isPortrait = height > width
            self.aspectRatio = width / height
        }
    }
    
    // 计算所有图片的尺寸信息
    private var imageDimensions: [ImageDimensions] {
        images.compactMap { imageName in
            if let image = UIImage(named: imageName) {
                return ImageDimensions(image: image)
            }
            return nil
        }
    }
    
    // 计算最适合的展示高度
    private var optimalHeight: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let portraitImages = imageDimensions.filter { $0.isPortrait }
        let landscapeImages = imageDimensions.filter { !$0.isPortrait }
        
        // 如果竖图数量大于等于横图，使用竖图高度
        if portraitImages.count >= landscapeImages.count {
            // 找出竖图中最合适的高度（考虑屏幕宽度）
            let portraitHeights = portraitImages.map { screenWidth / $0.aspectRatio }
            // 使用最小的竖图高度，避免太长
            return portraitHeights.min() ?? 450
        } else {
            // 如果横图更多，使用横图高度
            let landscapeHeights = landscapeImages.map { screenWidth / $0.aspectRatio }
            // 使用最大的横图高度，确保横图完整显示
            return landscapeHeights.max() ?? 450
        }
    }
    
    // 获取单个图片的展示尺寸
    private func getImageSize(for imageName: String) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        
        guard let image = UIImage(named: imageName) else {
            return CGSize(width: screenWidth, height: optimalHeight)
        }
        
        let aspectRatio = image.size.width / image.size.height
        let height = min(screenWidth / aspectRatio, optimalHeight)
        
        return CGSize(width: height * aspectRatio, height: height)
    }
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(0..<images.count, id: \.self) { index in
                if UIImage(named: images[index]) != nil {
                    let size = getImageSize(for: images[index])
                    Image(images[index])
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: size.width,
                            height: size.height,
                            alignment: .center
                        )
                        .frame(maxWidth: UIScreen.main.bounds.width)
                        .tag(index)
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: optimalHeight)
    }
}
