import SwiftUI

// 表情选择器视图
struct EmojiPickerView: View {
    let onEmojiSelected: (String) -> Void
    @Binding var isPresented: Bool
    
    // 表情分类
    private static let emojiCategories: [(String, [String])] = [
        ("常用", ["😊", "😂", "🥰", "😍", "😭", "😅", "😆", "🤣", "😘", "🥳"]),
        ("表情", ["😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "☺️", "😊",
                "😇", "🙂", "🙃", "😉", "😌", "😍", "🥰", "😘", "😗", "😙",
                "😚", "😋", "😛", "😝", "😜", "🤪", "🤨", "🧐", "🤓", "😎"]),
        ("手势", ["👍", "👎", "👊", "✊", "🤛", "🤜", "🤞", "✌️", "🤟", "🤘",
                "👌", "🤌", "🤏", "👈", "👉", "👆", "👇", "☝️", "✋", "🤚"]),
        ("食物", ["🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🫐", "🍈",
                "🍒", "🍑", "🥭", "🍍", "🥥", "🥝", "🍅", "🥑", "🥦", "🥬"]),
        ("动物", ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯",
                "🦁", "🐮", "🐷", "🐸", "🐵", "🐔", "🐧", "🐦", "🐤", "🦆"])
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部栏
            HStack {
                Text("选择表情")
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                Button("完成") {
                    isPresented = false
                }
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(UIColor.systemBackground))
            
            // 表情分类和内容
            TabView {
                ForEach(Self.emojiCategories, id: \.0) { category in
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 8), spacing: 12) {
                            ForEach(category.1, id: \.self) { emoji in
                                Button(action: {
                                    onEmojiSelected(emoji)
                                }) {
                                    Text(emoji)
                                        .font(.system(size: 28))
                                }
                            }
                        }
                        .padding()
                    }
                    .tabItem {
                        Text(category.0)
                    }
                }
            }
            .tabViewStyle(.page)
            .frame(height: 300)
            .onAppear {
                            UIPageControl.appearance().currentPageIndicatorTintColor = .black
                            UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
                        }
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

// TextView 包装器来获取光标位置
struct CustomTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var selectedRange: NSRange?
    @Binding var focusedField: PostInputViewModel.FocusField?
    let placeholder: String
    
    init(text: Binding<String>,
         selectedRange: Binding<NSRange?>,
         focusedField: Binding<PostInputViewModel.FocusField?> = .constant(nil),
         placeholder: String = "请分享周围的新鲜事儿") {
        self._text = text
        self._selectedRange = selectedRange
        self._focusedField = focusedField
        self.placeholder = placeholder
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = PlaceholderTextView() // 修改这里
        textView.delegate = context.coordinator
        textView.font = .systemFont(ofSize: 16)
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        textView.inputAccessoryView = nil
        textView.placeholderText = placeholder
        textView.placeholderColor = .systemGray3
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
           if uiView.text != text {
               uiView.text = text
           }
           if let range = selectedRange, uiView.selectedRange != range {
               uiView.selectedRange = range
           }
           (uiView as? PlaceholderTextView)?.setNeedsDisplay()
       }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextView
        private var lastSelectedRange: NSRange?
        
        init(_ parent: CustomTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
                  DispatchQueue.main.async {
                      self.parent.text = textView.text
                      self.parent.selectedRange = textView.selectedRange
                  }
                  (textView as? PlaceholderTextView)?.setNeedsDisplay()
              }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
                  if lastSelectedRange != textView.selectedRange {
                      lastSelectedRange = textView.selectedRange
                      DispatchQueue.main.async {
                          self.parent.selectedRange = textView.selectedRange
                      }
                  }
              }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
                   DispatchQueue.main.async {
                       self.parent.focusedField = .content
                   }
               }
               
        func textViewDidEndEditing(_ textView: UITextView) {
                   DispatchQueue.main.async {
                       // 只有当焦点确实在 content 时才清除
                       if self.parent.focusedField == .content {
                           self.parent.focusedField = nil
                       }
                   }
               }
    }
}

// 自定义 PlaceholderTextView 类
class PlaceholderTextView: UITextView {
    var placeholderText: String = "" {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var placeholderColor: UIColor = .systemGray3 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var text: String! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // 只在文本为空时绘制 placeholder
        if !text.isEmpty { return }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font ?? .systemFont(ofSize: 16),
            .foregroundColor: placeholderColor
        ]
        
        let drawRect = CGRect(
            x: textContainerInset.left + textContainer.lineFragmentPadding,
            y: textContainerInset.top,
            width: rect.width - textContainerInset.left - textContainerInset.right - 2 * textContainer.lineFragmentPadding,
            height: rect.height - textContainerInset.top - textContainerInset.bottom
        )
        
        placeholderText.draw(in: drawRect, withAttributes: attributes)
    }
}


