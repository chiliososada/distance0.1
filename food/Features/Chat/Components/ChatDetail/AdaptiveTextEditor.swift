import SwiftUI
import UIKit

struct AdaptiveTextEditor: View {
    @Binding var text: String
    let placeholder: String
    @Binding var isShowingEmoji: Bool
    
    // 默认参数
    private let font: Font
    private let width: CGFloat
    private let maxHeight: CGFloat
    private let innerPadding: CGFloat = 8
    
    init(
        text: Binding<String>,
        placeholder: String,
        isShowingEmoji: Binding<Bool>,
        font: Font = .body,
        width: CGFloat = UIScreen.main.bounds.width - 100,
        maxHeight: CGFloat = 210
    ) {
        self._text = text
        self.placeholder = placeholder
        self._isShowingEmoji = isShowingEmoji
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
        return max(30, min(paddingHeight, maxHeight))
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
            ChatCustomTextView(
                text: $text,
                isShowingEmoji: $isShowingEmoji,
                font: font,
                textViewHeight: calculatedHeight
            )
            .frame(height: calculatedHeight)
            .padding(innerPadding)
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

struct ChatCustomTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var isShowingEmoji: Bool
    let font: Font
    let textViewHeight: CGFloat
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: font.uiFontTextStyle)
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        textView.text = text
        
        // 监听键盘显示通知
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.showKeyboard),
            name: .showKeyboard,
            object: nil
        )
        
        context.coordinator.textView = textView
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        
        // 处理表情键盘切换
        if isShowingEmoji {
            let emojiView = EmojiKeyboardView(
                text: $text,
                isShowingEmoji: $isShowingEmoji
            )
            uiView.inputView = emojiView
        } else {
            uiView.inputView = nil
        }
        
        uiView.reloadInputViews()
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: ChatCustomTextView
        weak var textView: UITextView?
        
        init(_ parent: ChatCustomTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
        
        @objc func showKeyboard() {
            textView?.becomeFirstResponder()
        }
    }
}

class EmojiKeyboardView: UIInputView {
    private let emojiCategories: [(String, [String])] = [
        ("常用", ["😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "☺️", "😊"]),
        ("表情", ["😇", "🙂", "🙃", "😉", "😌", "😍", "🥰", "😘", "😗", "😙"]),
        ("手势", ["👍", "👎", "👊", "✊", "🤛", "🤜", "🤞", "✌️", "🤟", "🤘"]),
        ("动物", ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯"]),
        ("食物", ["🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🍈", "🍒"])
    ]
    
    @Binding var text: String
    @Binding var isShowingEmoji: Bool
    
    init(text: Binding<String>, isShowingEmoji: Binding<Bool>) {
        self._text = text
        self._isShowingEmoji = isShowingEmoji
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300), inputViewStyle: .keyboard)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        let container = UIView()
        container.backgroundColor = .systemBackground
        
        // 添加表情按钮网格
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 45, height: 45)
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.minimumLineSpacing = 10
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // 设置布局
        addSubview(container)
        container.addSubview(collectionView)
        
        container.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            collectionView.topAnchor.constraint(equalTo: container.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        // 添加顶部分割线
        let topSeparator = UIView()
        topSeparator.backgroundColor = .separator
        container.addSubview(topSeparator)
        topSeparator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topSeparator.topAnchor.constraint(equalTo: container.topAnchor),
            topSeparator.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            topSeparator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}

class EmojiCell: UICollectionViewCell {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 30)
        
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            label.heightAnchor.constraint(equalTo: contentView.heightAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EmojiKeyboardView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojiCategories.flatMap { $0.1 }.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
        let emojis = emojiCategories.flatMap { $0.1 }
        cell.label.text = emojis[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emojis = emojiCategories.flatMap { $0.1 }
        text.append(emojis[indexPath.item])
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
