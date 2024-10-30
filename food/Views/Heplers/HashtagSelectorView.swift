import SwiftUI

// MARK: - Hashtag Selector View
struct HashtagSelectorView: View {
    let hashtags: [String]
    let onSelect: (String) -> Void
    @State private var inputTag: String = ""
    @State private var isEditing = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // 固定在顶部的输入区域
                    VStack(spacing: 0) {
                        HStack {
                            TextField("输入标签", text: $inputTag)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .submitLabel(.done)
                                .onAppear {
                                    if inputTag.isEmpty {
                                        inputTag = "#"
                                    }
                                }
                                .onSubmit {
                                    submitTag()
                                }
                            
                            Button(action: {
                                submitTag()
                            }) {
                                Text("完成")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 16))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        Divider()
                            .padding(.horizontal, 16)
                    }
                    .background(Color(UIColor.systemBackground))
                    
                    // 标签列表
                    ForEach(hashtags, id: \.self) { tag in
                        Button(action: { onSelect(tag) }) {
                            HStack {
                                Text(tag)
                                    .foregroundColor(.blue)
                                    .font(.system(size: 16))
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                            .background(Color(UIColor.systemBackground))
                        }
                        Divider()
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(Color(.systemGray6))
        }
        .frame(height: 200)
    }
    
    private func submitTag() {
        var tagToAdd = inputTag.trimmingCharacters(in: .whitespaces)
        if !tagToAdd.isEmpty {
            // 确保有 # 前缀
            if !tagToAdd.hasPrefix("#") {
                tagToAdd = "#" + tagToAdd
            }
            onSelect(tagToAdd)
            inputTag = "#" // 重置为 # 而不是空字符串
        }
    }
}

// 预览
struct HashtagSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            HashtagSelectorView(
                hashtags: [
                    "#美食",
                    "#旅行",
                    "#摄影",
                    "#生活",
                    "#音乐",
                    "#电影",
                    "#读书",
                    "#运动"
                ],
                onSelect: { tag in
                    print("Selected tag: \(tag)")
                }
            )
        }
        .background(Color.gray.opacity(0.1))
    }
}
