
import SwiftUI

struct TabStateScrollView<Content: View>: View {
    var axis: Axis.Set
    var showsIndicator: Bool
    @Binding var tabState: Visibility
    @Binding var isNavigationBarHidden: Bool
    @EnvironmentObject private var tabBarManager: TabBarManager  // 添加这行
    var content: Content
    
    init(axis: Axis.Set, showsIndicator: Bool, tabState: Binding<Visibility>, isNavigationBarHidden: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self.axis = axis
        self.showsIndicator = showsIndicator
        self._tabState = tabState
        self._isNavigationBarHidden = isNavigationBarHidden
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
    
    func handleTabState(_ gesture: UIPanGestureRecognizer) {
        let velocityY = gesture.velocity(in: gesture.view).y
        let translation = gesture.translation(in: gesture.view).y
        
        let swipeUpThreshold: CGFloat = 50
        let swipeDownThreshold: CGFloat = 30
        
        withAnimation(.easeInOut(duration: 0.2)) {
            if velocityY < 0 {
                // 向上滑动
                if -(velocityY / 5) > swipeUpThreshold && tabState == .visible {
                    tabState = .hidden
                    isNavigationBarHidden = true
                    tabBarManager.isNavigatingInTab = true  // 添加这行
                }
            } else {
                // 向下滑动
                if (velocityY / 5) > swipeDownThreshold && tabState == .hidden {
                    tabState = .visible
                    isNavigationBarHidden = false
                    tabBarManager.isNavigatingInTab = false  // 添加这行
                }
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
                        gesture.delegate = context.coordinator  // Set delegate to avoid conflicts
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
                // Avoid conflict with ScrollView gestures
                if otherGestureRecognizer.view is UIScrollView {
                    return true
                }
                return false
            }
        }
    }
}
