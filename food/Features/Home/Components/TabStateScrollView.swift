//
//  TabStateScrollView.swift
//  food
//
//  Created by toyousoft on 2024/11/21.
//

import SwiftUI

struct TabStateScrollView<Content: View>: View {
    var axis: Axis.Set
    var showsIndicator: Bool
    var onStateChange: (Bool) -> Void
    var content: Content
    
    @State private var lastOffset: CGFloat = 0
    @State private var currentOffset: CGFloat = 0
    @State private var isVisible: Bool = true
    
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
        let velocityY = gesture.velocity(in: gesture.view).y
        
        switch gesture.state {
        case .changed:
            handleScrollChange(velocityY: velocityY)
        case .ended:
            lastOffset = currentOffset
        default:
            break
        }
    }
    
    private func handleScrollChange(velocityY: CGFloat) {
        let swipeUpThreshold: CGFloat = 40
        let swipeDownThreshold: CGFloat = 25
        
        withAnimation(.spring(response: 0.3, dampingFraction: 1)) {
            if velocityY < 0 {
                // 向上滑动
                if -(velocityY / 5) > swipeUpThreshold && isVisible {
                    isVisible = false
                    onStateChange(false)
                }
            } else {
                // 向下滑动
                if (velocityY / 5) > swipeDownThreshold && !isVisible {
                    isVisible = true
                    onStateChange(true)
                }
            }
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

