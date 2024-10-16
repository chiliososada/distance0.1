import SwiftUI

struct VerticalLineAnimationView: View {
    @State private var firstLineProgress: CGFloat = 0.0
    @State private var secondLineProgress: CGFloat = 0.0

    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack(spacing: 70) { // 减小线条间距
                    Spacer()
                    
                    // 第一条线（短的，圆角）
                    Line(height: geometry.size.height * 0.7 * 0.6) // 使用屏幕的 40% 高度的 50% 作为第一条线的高度
                        .trim(from: 0, to: firstLineProgress)
                        .stroke(Color.black, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 2, height: geometry.size.height * 0.6 * 0.5)
                        .animation(.linear(duration: 1), value: firstLineProgress)
                    
                 
                    
                    // 第二条线（长的，圆角）
                    Line(height: geometry.size.height * 0.7) // 使用屏幕的 60% 高度作为第二条线的高度
                        .trim(from: 0, to: secondLineProgress)
                        .stroke(Color.black, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 2, height: geometry.size.height * 0.6)
                        .animation(.linear(duration: 1.5), value: secondLineProgress)
                    
                    Spacer()
                }
                .onAppear {
                    // 先动画绘制第一条线
                    withAnimation(.linear(duration: 1)) {
                        firstLineProgress = 1.0
                    }
                    
                    // 延迟 1 秒后再绘制第二条线
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation(.linear(duration: 1.5)) {
                            secondLineProgress = 1.0
                        }
                    }
                }
            }
            .frame(height: 400) // 设置 GeometryReader 的高度
            .padding(.top, 50) // 顶部留出空间
        }
    }
}

struct Line: Shape {
    var height: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}

struct VerticalLineAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        VerticalLineAnimationView()
    }
}
