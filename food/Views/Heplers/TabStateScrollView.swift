
//
//  TabStateScrollView.swift
//
//  Created by toyousoft on 2024/10/04.
//
import SwiftUI
struct TabStateScrollView<Content: View>: View {
    var axis: Axis.Set
    var showsIndicator: Bool
    @Binding var tabState: Visibility
    var content: Content
    
    init(axis: Axis.Set, showsIndicator: Bool, tabState: Binding<Visibility>, @ViewBuilder content: @escaping () -> Content) {
        self.axis = axis
        self.showsIndicator = showsIndicator
        self._tabState = tabState
        self.content = content()
    }
    
    var body: some View {
        /// This Project Supports iOS 16 & iOS 17
        if #available(iOS 17, *) {
            ScrollView(axis) {
                content
            }
            .scrollIndicators(showsIndicator ? .visible : .hidden)
            .background {
                CustomGesture {
                    handleTabState($0)
                }
            }
        } else {
            ScrollView(axis, showsIndicators: showsIndicator, content: {
                content
            })
            .background {
                CustomGesture {
                    handleTabState($0)
                }
            }
        }
    }
    
    /// Handling Tab State on Swipe (Moved outside of body)
    func handleTabState(_ gesture: UIPanGestureRecognizer) {
        let velocityY = gesture.velocity(in: gesture.view).y
        
        // Define swipe thresholds
        let swipeUpThreshold: CGFloat = 60
        let swipeDownThreshold: CGFloat = 40
        
        if velocityY < 0 {
            if -(velocityY / 5) > swipeUpThreshold && tabState == .visible {
                tabState = .hidden
            }
        } else {
            /// Swiping Down
            if (velocityY / 5) > swipeDownThreshold && tabState == .hidden {
                tabState = .visible
               
            }
        }
    }

    fileprivate struct CustomGesture: UIViewRepresentable {
        var onChange: (UIPanGestureRecognizer) -> ()
        private let gestureID = UUID().uuidString
        
        func makeUIView(context: Context) -> UIView {
            return UIView()
        }

        func updateUIView(_ uiView: UIView, context: Context) {
            DispatchQueue.main.async {
                if let superView = uiView.superview?.superview {
                  
                    if !(superView.gestureRecognizers?.contains(where: { $0.name == gestureID }) ?? false) {
                        let gesture = UIPanGestureRecognizer(target: context.coordinator,
                                                             action: #selector(context.coordinator.gestureChange(gesture:)))
                        gesture.name = gestureID
                        gesture.delegate = context.coordinator  // 设置 delegate
                        superView.addGestureRecognizer(gesture)
                        
                    }
                }
            }
        }

        func makeCoordinator() -> Coordinator {
            return Coordinator(onChange: onChange)
        }
        
        class Coordinator: NSObject, UIGestureRecognizerDelegate {
            var onChange: (UIPanGestureRecognizer) -> ()
            
            init(onChange: @escaping (UIPanGestureRecognizer) -> Void) {
                self.onChange = onChange
              
            }
            
            @objc
            func gestureChange(gesture: UIPanGestureRecognizer) {
              
                onChange(gesture)
            }
            
            func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                   shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
                // 确保 ScrollView 的手势不与自定义手势冲突
                if otherGestureRecognizer.view is UIScrollView {
                    return true
                }
                return false
            }
        }
    }
}
