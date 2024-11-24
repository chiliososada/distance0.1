import SwiftUI

struct TabStateScrollView<Content: View>: View {
    // MARK: - Properties
    var axis: Axis.Set
    var showsIndicator: Bool
    var onStateChange: (Bool) -> Void
    var content: Content
    
    // MARK: - State
    @State private var isVisible: Bool = true
    
    // MARK: - Initialization
    init(
        axis: Axis.Set,
        showsIndicator: Bool,
        onStateChange: @escaping (Bool) -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axis = axis
        self.showsIndicator = showsIndicator
        self.onStateChange = onStateChange
        self.content = content()
    }
    
    var body: some View {
        if #available(iOS 17, *) {
            ScrollView(axis) {
                content
            }
            .scrollIndicators(showsIndicator ? .visible : .hidden)
            .background {
                CustomGesture {
                    handleGestureChange($0)
                }
                .id("mainGesture")
            }
        } else {
            ScrollView(axis, showsIndicators: showsIndicator) {
                content
            }
            .background {
                CustomGesture {
                    handleGestureChange($0)
                }
                .id("mainGesture")
            }
        }
    }
    
    private func handleGestureChange(_ gesture: UIPanGestureRecognizer) {
        let velocityY = gesture.velocity(in: gesture.view).y
        
        // 只要有任何方向的移动就立即响应
        if velocityY < 0 {
            if isVisible {
//                print("👆 向上滑动，隐藏导航栏，velocityY: \(velocityY)")
                isVisible = false
                onStateChange(false)
            }
        } else if velocityY > 0 {
            if !isVisible {
//                print("👇 向下滑动，显示导航栏，velocityY: \(velocityY)")
                isVisible = true
                onStateChange(true)
            }
        }
    }
}

// MARK: - Custom Gesture Handler
fileprivate struct CustomGesture: UIViewRepresentable {
    static private let gestureKey = "TabStateScrollViewGesture"
    var onChange: (UIPanGestureRecognizer) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        // 使用静态属性
        view.tag = CustomGesture.gestureKey.hashValue
        
        let gesture = createGesture(context: context)
        view.addGestureRecognizer(gesture)
        return view
    }
    
    private func createGesture(context: Context) -> UIPanGestureRecognizer {
        let gesture = UIPanGestureRecognizer(target: context.coordinator,
                                           action: #selector(context.coordinator.gestureChange(gesture:)))
        gesture.delegate = context.coordinator
        gesture.name = CustomGesture.gestureKey
        
        // 最大化手势识别器的响应性
        gesture.delaysTouchesBegan = false
        gesture.delaysTouchesEnded = false
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1
        
        return gesture
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // 检查 superView 是否已经处理过
        if let superView = uiView.superview?.superview {
            let key = UnsafeRawPointer(bitPattern: CustomGesture.gestureKey.hashValue)!
            
            // 使用关联对象检查是否已添加过手势识别器
            if objc_getAssociatedObject(superView, key) == nil {
                let gesture = createGesture(context: context)
                superView.addGestureRecognizer(gesture)
                
                // 标记已处理
                objc_setAssociatedObject(superView, key, true, .OBJC_ASSOCIATION_RETAIN)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onChange: onChange)
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var onChange: (UIPanGestureRecognizer) -> Void
        
        init(onChange: @escaping (UIPanGestureRecognizer) -> Void) {
            self.onChange = onChange
            super.init()
        }
        
        @objc
        func gestureChange(gesture: UIPanGestureRecognizer) {
            if gesture.state == .changed {
                onChange(gesture)
            }
        }
        
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            return true
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                              shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return false
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                              shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return false
        }
    }
}
