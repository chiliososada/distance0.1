import SwiftUI

// 顶部公告视图
struct AnnouncementView: View {
    var body: some View {
        VStack(spacing: 4) { // 间距更小
            Text("15:00")
                .font(.system(size: 24, weight: .bold)) // 缩小字体
                .foregroundColor(.black) // 主要文本改为黑色
            
            Text("Exclusive shirt for 15 minutes.")
                .font(.subheadline) // 缩小次要文本
                .foregroundColor(.black) // 灰色次要文本
            
            Text("www.Nike.com/AJPicard")
                .font(.footnote) // 链接文本更小
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity) // 占满宽度
        .padding(8) // 减少整体的 padding
        .background(Color.blue.opacity(0.4)) // 半透明灰色背景
        .cornerRadius(12) // 较小的圆角
        .padding(.horizontal)
    }
}

// 预览
struct AnnouncementView_Previews: PreviewProvider {
    static var previews: some View {
        AnnouncementView()
            .previewLayout(.sizeThatFits) // 预览为适应内容的大小
            .padding() // 给预览加一点 padding 以显示效果
    }
}
