
import SwiftUI

struct HashtagSelectorView: View {
    let hashtags: [String]
    let onSelect: (String) -> Void
    @State private var inputTag: String = ""
    @State private var filteredTags: [String] = []  // 添加过滤后的标签数组
    @FocusState private var isInputFocused: Bool  // 添加焦点状态
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
                                .focused($isInputFocused)  // 添加这一行
                                .onAppear {
                                    if inputTag.isEmpty {
                                        inputTag = "#"
                                        filteredTags = hashtags  // 初始显示所有标签
                                    }
                                    // 设置焦点
                                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                      isInputFocused = true
                                  }
                                }
                                .onChange(of: inputTag) {
                                    filterTags(with: inputTag)  // 当输入改变时进行过滤
                                }
                                .onSubmit {
                                    submitTag()
                                }
                            
                            Button(action: {
                                submitTag()
                            }) {
                                Text("添加")
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
                    
                    // 标签列表 (使用过滤后的标签)
                    ForEach(filteredTags, id: \.self) { tag in
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
    
    // 添加过滤方法
    private func filterTags(with searchText: String) {
        let searchTerm = searchText.hasPrefix("#") ?
            String(searchText.dropFirst()) : searchText
            
        if searchTerm.isEmpty {
            filteredTags = hashtags  // 如果搜索词为空，显示所有标签
        } else {
            filteredTags = hashtags.filter { tag in
                let tagText = tag.hasPrefix("#") ?
                    String(tag.dropFirst()) : tag
                return tagText.localizedCaseInsensitiveContains(searchTerm)
            }
        }
    }
    
    private func submitTag() {
        var tagToAdd = inputTag.trimmingCharacters(in: .whitespaces)
        if !tagToAdd.isEmpty {
            if !tagToAdd.hasPrefix("#") {
                tagToAdd = "#" + tagToAdd
            }
            onSelect(tagToAdd)
            inputTag = "#"
            filteredTags = hashtags  // 重置显示所有标签
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
                    "#美食", "#美女", "#美景",  // 添加一些相似的标签以测试搜索
                    "#旅行", "#旅游", "#旅拍",
                    "#摄影", "#摄像", "#设计",
                    "#生活", "#时尚", "#食物",
                    "#音乐", "#艺术", "#影视",
                    "#电影", "#动漫", "#读书",
                    "#运动", "#游戏", "#娱乐"
                ],
                onSelect: { tag in
                    print("Selected tag: \(tag)")
                }
            )
        }
        .background(Color.gray.opacity(0.1))
    }
}
