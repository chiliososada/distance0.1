import SwiftUI

struct SearchAndFilterView: View {
    @Binding var search: String
    @State private var showFilterView = false  // 控制弹出视图显示

    var body: some View {
        VStack {
            // 搜索框
            HStack(spacing: 8) {  // 减少HStack的间距
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("请输入要查找的话题，标签等...", text: $search)
                        .padding(.vertical, 2)  // 减少 TextField 的内边距
                        .font(.system(size: 14, weight: .regular))  // 调整字体大小
                        .foregroundColor(.black)
                        .accentColor(.gray)
                }
                .padding(8)  // 减少HStack内的padding
                .background(Color(UIColor.white))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)  // Gray border with 1 point thickness
                )

                // 过滤按钮
                Button(action: {
                    showFilterView.toggle()  // 点击显示过滤器视图
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.black)
                        .padding(8)  // 减少按钮的padding
                        .background(Color(UIColor.white))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)  // Gray border with 1 point thickness
                        )
                }
            }
            .padding(.horizontal)  // 仅调整左右两侧的padding，保持上下的紧凑布局
        }
        // 用 .sheet 来展示底部弹出的过滤视图
        .sheet(isPresented: $showFilterView) {
            SearchFilterView(showFilterView: $showFilterView)  // 将 showFilterView 传递给 sheet 内容
        }
    }
}



// Preview
struct SearchAndFilterView_Previews: PreviewProvider {
    @State static var search = "请输入要查找的话题，标签等..."

    static var previews: some View {
        SearchAndFilterView(search: $search)
    }
}
