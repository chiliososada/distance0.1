import SwiftUI

struct TabStateScrollView<Content: View>: View {
    // MARK: - Properties
    var axis: Axis.Set
    var showsIndicator: Bool
    var onStateChange: (Bool) -> Void
    var content: Content
    
    // MARK: - State
    @State private var lastOffset: CGFloat = 0
    @State private var currentOffset: CGFloat = 0
    @State private var isVisible: Bool = true
    @State private var lastScrollDirection: CGFloat = 0
    @State private var lastUpdateTime: Date = Date()
    
    // 调整这些值以获得更好的滚动体验
    private let minimumScrollDelta: CGFloat = 80 // 降低一点触发阈值
    private let minimumTimeDelta: TimeInterval = 0.08 // 稍微减少时间间隔
    
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
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: ScrollOffsetKey.self, value: proxy.frame(in: .named("scroll")).minY)
                        }
                    )
            }
            .scrollIndicators(showsIndicator ? .visible : .hidden)
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetKey.self) { offset in
                handleScrollOffset(offset)
            }
            .background {
                CustomGesture {
                    handleGestureChange($0)
                }
            }
        } else {
            ScrollView(axis, showsIndicators: showsIndicator) {
                content
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: ScrollOffsetKey.self, value: proxy.frame(in: .named("scroll")).minY)
                        }
                    )
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetKey.self) { offset in
                handleScrollOffset(offset)
            }
            .background {
                CustomGesture {
                    handleGestureChange($0)
                }
            }
        }
    }
    
    private func handleScrollOffset(_ offset: CGFloat) {
        currentOffset = offset
    }
    
    private func handleGestureChange(_ gesture: UIPanGestureRecognizer) {
        let currentTime = Date()
        let velocityY = gesture.velocity(in: gesture.view).y
        
        switch gesture.state {
        case .changed:
            guard currentTime.timeIntervalSince(lastUpdateTime) >= minimumTimeDelta else { return }
            
            let currentDirection: CGFloat = velocityY > 0 ? 1.0 : -1.0
            
            if abs(velocityY) > minimumScrollDelta && currentDirection * lastScrollDirection <= 0 {
                lastScrollDirection = currentDirection
                let shouldShow = velocityY > 0
                
                if shouldShow != isVisible {
                    isVisible = shouldShow
                    lastUpdateTime = currentTime
                    onStateChange(shouldShow)
                }
            }
            
        case .ended, .cancelled:
            lastOffset = currentOffset
            
        default:
            break
        }
    }
}
// MARK: - Supporting Types
fileprivate struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Custom Gesture Handler
fileprivate struct CustomGesture: UIViewRepresentable {
    var onChange: (UIPanGestureRecognizer) -> Void
    private let gestureID = UUID().uuidString
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            if let superView = uiView.superview?.superview {
                if !(superView.gestureRecognizers?.contains(where: { $0.name == gestureID }) ?? false) {
                    let gesture = UIPanGestureRecognizer(target: context.coordinator,
                                                       action: #selector(context.coordinator.gestureChange(gesture:)))
                    gesture.name = gestureID
                    gesture.delegate = context.coordinator
                    superView.addGestureRecognizer(gesture)
                }
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
        }
        
        @objc
        func gestureChange(gesture: UIPanGestureRecognizer) {
            onChange(gesture)
        }
        
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            return otherGestureRecognizer.view is UIScrollView
        }
    }
}
