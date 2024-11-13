//
//  PostInputView.swift
//  food
//
//  Created by toyousoft on 2024/10/29.
//

import SwiftUI
import PhotosUI
import MapItemPicker


// MARK: - Main View
struct PostInputView: View {
    @StateObject private var viewModel = PostInputViewModel()
       @Environment(\.dismiss) private var dismiss
       @Binding var isPresented: Bool
       @Binding var selectedTab: TabRoute  // Change from Int to TabRoute
       @FocusState private var focusedField: PostInputViewModel.FocusField?
    
    private enum Layout {
        static let spacing: CGFloat = 16
        static let toolbarHeight: CGFloat = 44
        static let titleTopPadding: CGFloat = 20  // 添加标题顶部间距常量
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: Layout.spacing) {
                        Spacer().frame(height: Layout.titleTopPadding)
                        if !viewModel.selectedImages.isEmpty {
                            ImageGridSection(images: $viewModel.selectedImages)
                                .padding(.top)
                        }
                        
                        TitleInputSection(
                            title: $viewModel.title,
                            focusedField: $focusedField
                        )
                        
                        Divider()
                            .padding(.horizontal)
                        
                        LocationSection(
                            locationText: viewModel.userLocationText,
                            onLocationTap: viewModel.showLocationPicker
                        )
                        
                        PostInputTagsSection(tags: viewModel.selectedTags) { tag in
                            viewModel.removeTag(tag)
                        }
                        
                        ContentInputSection(
                            content: $viewModel.content,
                            selectedRange: $viewModel.contentSelectedRange,
                            focusedField: $viewModel.focusedField
                        )
                    }
                    .padding(.bottom, viewModel.keyboardHeight > 0 ? viewModel.keyboardHeight - 50 : 0)
                }
                
                if viewModel.isShowingHashtagSelector {
                    HashtagSelectorView(
                        hashtags: viewModel.suggestedTags,
                        onSelect: viewModel.insertHashtag
                    )
                    .transition(.move(edge: .bottom))
                }
                
                if viewModel.shouldShowToolbar {
                    ToolbarSection(viewModel: viewModel)
                        .transition(.move(edge: .bottom))
                }
            }
            .navigationBarItems(
                           leading: DismissButton(
                               dismiss: dismiss,
                               selectedTab: .home,
                               isPresented: $isPresented,
                               viewModel: viewModel
                           ),
                           trailing: NextStepButton(viewModel: viewModel)
                       )
            .navigationDestination(isPresented: $viewModel.showSecondView) {
                           PublishBlogView(viewModel: viewModel)
                       }
            .onChange(of: focusedField) { oldValue, newValue in
                viewModel.focusedField = newValue
            }
            
            .sheet(isPresented: $viewModel.isShowingImagePicker) {
                MultiImagePicker(images: $viewModel.selectedImages)
            }
            .sheet(isPresented: $viewModel.isShowingEmojiPicker) {
                EmojiPickerView(
                    onEmojiSelected: viewModel.insertEmoji,
                    isPresented: $viewModel.isShowingEmojiPicker
                )
                .presentationDetents([.height(350)])
            }
            .mapItemPicker(isPresented: $viewModel.showingPicker) { item in
                if let name = item?.placemark.name {
                    viewModel.userLocationText = name
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct ImageGridSection: View {
    @Binding var images: [UIImage] // 改为绑定，以便能够更新视图
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(images.indices, id: \.self) { index in
                    ImageTile(image: images[index]) {
                        images.remove(at: index) // 删除选中的图像
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
// 新的下一步按钮组件
struct NextStepButton: View {
    @ObservedObject var viewModel: PostInputViewModel
    
    var body: some View {
        Button(action: {
            viewModel.showSecondView = true
        }) {
            Text("下一步")
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .foregroundColor(.white)
                .background(Color.black)
                .cornerRadius(25)
        }
    }
}
struct TitleInputSection: View {
    @Binding var title: String
    @FocusState.Binding var focusedField: PostInputViewModel.FocusField?
    
    var body: some View {
        HStack {
            TextField("标题", text: $title)
                .font(.system(size: 18, weight: .medium))
                .focused($focusedField, equals: .title)
            
            if !title.isEmpty {
                Button(action: { title = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            
            Text("\(title.count)/20")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .frame(width: 40)
        }
        .padding(.horizontal)
        
    }
}

struct LocationSection: View {
    let locationText: String
    let onLocationTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !locationText.isEmpty {
                HStack {
                    Text("发送到这里:")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Button(action: onLocationTap) {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.blue)
                            Text(locationText)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
    }
}

struct PostInputTagsSection: View {
    let tags: [String]
    let onRemove: (String) -> Void
    
    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                TagView(tag: tag) {
                    onRemove(tag)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct TagView: View {
    let tag: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .foregroundColor(.blue)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
        }
        .font(.system(size: 14))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
    }
}

struct ContentInputSection: View {
    @Binding var content: String
    @Binding var selectedRange: NSRange?
    @Binding var focusedField: PostInputViewModel.FocusField?
    
    var body: some View {
        CustomTextView(
            text: $content,
            selectedRange: $selectedRange,
            focusedField: $focusedField
        )
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(minHeight: 300)
        .padding(.horizontal)
    }
}


// MARK: - ToolbarSection View
struct ToolbarSection: View {
    @ObservedObject var viewModel: PostInputViewModel
    
    private enum Layout {
        static let spacing: CGFloat = 24
        static let iconPadding: CGFloat = 8
        static let toolbarHeight: CGFloat = 44
        
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: Layout.spacing) {
                toolbarLeadingButtons
                Spacer()
                toolbarTrailingContent
            }
            .padding(.horizontal)
            .frame(height: Layout.toolbarHeight)
            .background(Color(UIColor.systemBackground))
        }
    }
    
    // MARK: - Leading Buttons
    private var toolbarLeadingButtons: some View {
        HStack(spacing: Layout.spacing) {
            mediaButton
            emojiButton
            hashtagButton
        }
    }
    
    private var mediaButton: some View {
        ToolbarButton(
            iconName: "photo",
            isSelected: false,
            action: { viewModel.isShowingImagePicker = true }
        )
    }
    
    private var emojiButton: some View {
        ToolbarButton(
            iconName: "face.smiling",
            isSelected: false,
            action: { viewModel.isShowingEmojiPicker = true }
        )
    }
    
    private var hashtagButton: some View {
        ToolbarButton(
            iconName: "number",
            isSelected: viewModel.isShowingHashtagSelector,
            action: {
                withAnimation {
                    viewModel.isShowingHashtagSelector.toggle()
                    // 如果是收起标签选择器,确保内容输入框保持焦点
                    if !viewModel.isShowingHashtagSelector {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            viewModel.focusedField = .content
                        }
                    }
                }
            }
        )
    }
    
    // MARK: - Trailing Content
    private var toolbarTrailingContent: some View {
        HStack(spacing: Layout.spacing) {
            keyboardDismissButton
            characterCounter
        }
    }
    
    private var keyboardDismissButton: some View {
        Button(action: dismissKeyboard) {
            Image(systemName: "keyboard.chevron.compact.down.fill")
                .foregroundColor(.black)
        }
    }
    
    private var characterCounter: some View {
        Text("\(viewModel.characterCount)/777")
            .font(.system(size: 12))
            .foregroundColor(.gray)
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

// MARK: - Toolbar Button Component
struct ToolbarButton: View {
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .foregroundColor(isSelected ? .blue : .black)
                .frame(width: 24, height: 24) // Fixed size for consistency
        }
    }
}

struct PublishButton: View {
    @Binding var showSecondView: Bool
    
    var body: some View {
        Button(action: { showSecondView = true }) {
            Text("下一步")
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .foregroundColor(.white)
                .background(Color.black)
                .cornerRadius(25)
        }
    }
}
struct ImageTile: View {
    let image: UIImage
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .cornerRadius(8)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.red))
                    .shadow(radius: 2)
            }
            .padding(5)
        }
    }
}

// MARK: - Preview Provider
struct PostInputView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PostInputView(
                isPresented: .constant(true),
                selectedTab: .constant(.home)  // Use TabRoute.home
            )
        }
    }
}
