import SwiftUI
import UIKit

struct AdaptiveTextEditor: View {
    @Binding var text: String
    let placeholder: String
    
    // 默认参数
    private let font: Font
    private let width: CGFloat
    private let maxHeight: CGFloat
    private let innerPadding: CGFloat = 8
    
    init(
        text: Binding<String>,
        placeholder: String,
        font: Font = .body,
        width: CGFloat = UIScreen.main.bounds.width - 100, // 减去左右按钮和边距的空间
        maxHeight: CGFloat = 210
    ) {
        self._text = text
        self.placeholder = placeholder
        self.font = font
        self.width = width
        self.maxHeight = maxHeight
    }
    
    // 使用 UIKit 计算文本高度
    private var calculatedHeight: CGFloat {
        let height = text.boundingRect(
            with: CGSize(
                width: width - innerPadding * 2 - 12,
                height: UIScreen.main.bounds.height
            ),
            options: .usesLineFragmentOrigin,
            attributes: [.font: UIFont.preferredFont(forTextStyle: font.uiFontTextStyle)],
            context: nil
        ).height
        
        // 添加内边距并限制最大高度
        let paddingHeight = height + innerPadding * 2
        return max(30, min(paddingHeight, maxHeight)) // 确保最小高度为30
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // 占位文本
            if text.isEmpty {
                Text(placeholder)
                    .font(font)
                    .foregroundColor(Color(.placeholderText))
                    .padding(.horizontal, innerPadding)
                    .padding(.vertical, innerPadding)
            }
            
            // 文本输入框
            TextEditor(text: $text)
                .font(font)
                .frame(height: calculatedHeight)
                .padding(innerPadding)
                .scrollContentBackground(.hidden)
        }
        .frame(height: calculatedHeight)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 0.5)
        )
    }
}

// 扩展方法，方便自定义
extension AdaptiveTextEditor {
    func font(_ font: Font) -> AdaptiveTextEditor {
        AdaptiveTextEditor(
            text: $text,
            placeholder: placeholder,
            font: font,
            width: width,
            maxHeight: maxHeight
        )
    }
    
    func frame(width: CGFloat, maxHeight: CGFloat) -> AdaptiveTextEditor {
        AdaptiveTextEditor(
            text: $text,
            placeholder: placeholder,
            font: font,
            width: width,
            maxHeight: maxHeight
        )
    }
}

// Font 扩展，用于转换 SwiftUI Font 到 UIKit TextStyle
extension Font {
    var uiFontTextStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        default: return .body
        }
    }
}


