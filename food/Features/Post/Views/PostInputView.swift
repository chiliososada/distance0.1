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
      @Binding var selectedTab: Int
      @FocusState private var focusedField: PostInputViewModel.FocusField?
    
    
    private enum Layout {
           static let spacing: CGFloat = 16
           static let toolbarHeight: CGFloat = 44
           static let maxCharacterCount = 777
        static let hashtagSelectorHeight: CGFloat = 200
       }
   
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: Layout.spacing) {
                        if !viewModel.selectedImages.isEmpty {
                            imageSection
                                .padding(.top)
                        }
                        
                        titleInputSection
                        
                        Divider()
                            .padding(.horizontal)
                        
                        locationSection
                        tagsSection
                        contentInputSection
                        
                        
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
                if viewModel.shouldShowToolbar{
                    toolbarSection
                        .transition(.move(edge: .bottom))
                }
            }  .navigationBarItems(
                leading: dismissButton,
                trailing: publishButton
            )
            
        }
        .onChange(of: focusedField) {
            viewModel.focusedField = focusedField
        }
        .onChange(of: viewModel.isShowingHashtagSelector) {
            if viewModel.isShowingHashtagSelector {
                // 确保内容输入框保持焦点
                focusedField = .content
            }
        }
            .sheet(isPresented: $viewModel.isShowingImagePicker) {
                MultiImagePicker(images: $viewModel.selectedImages)
            }
            .sheet(isPresented: $viewModel.isShowingEmojiPicker) {
                EmojiPickerView(
                    onEmojiSelected: { emoji in
                        viewModel.insertEmoji(emoji)
                    },
                    isPresented: $viewModel.isShowingEmojiPicker
                )
                .presentationDetents([.height(350)])
            }
            
            .mapItemPicker(isPresented: $viewModel.showingPicker) { item in
                if let name = item?.placemark.name {
                    viewModel.userLocationText = name
                }
                // 当 picker 关闭时重新设置键盘观察者
                               DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                   viewModel.setupKeyboardObservers()
                               }
            }
            
          
        
    }
    private func dismissKeyboard() {
          focusedField = nil
          UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
      }
    private var titleInputSection: some View {
          HStack {
              TextField("标题", text: $viewModel.title)
                  .font(.system(size: 18, weight: .medium))
                  .focused($focusedField, equals: .title)
                  .onChange(of: focusedField) {
                      viewModel.focusedField = focusedField
                  }
              if !viewModel.title.isEmpty {
                  Button(action: { viewModel.title = "" }) {
                      Image(systemName: "xmark.circle.fill")
                          .foregroundColor(.gray)
                  }
              }
              
              Text("\(viewModel.title.count)/\(20)")
                  .font(.system(size: 12))
                  .foregroundColor(.gray)
                  .frame(width: 40)
          }
          .padding(.horizontal)
          .padding(.top, Layout.spacing)
      }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if !viewModel.userLocationText.isEmpty {
                    Text("发送到这里:")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        viewModel.showLocationPicker()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.blue)
                            Text(viewModel.userLocationText)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    // 图片展示区域
       private var imageSection: some View {
           ScrollView(.horizontal, showsIndicators: false) {
               HStack(spacing: 10) {
                   ForEach(viewModel.selectedImages.indices, id: \.self) { index in
                       ImageTile(
                           image: viewModel.selectedImages[index],
                           onDelete: {
                               viewModel.selectedImages.remove(at: index)
                           }
                       )
                   }
               }
               .padding(.horizontal)
           }
       }
    private var dismissButton: some View {
        Button(action: {
            dismiss()
            selectedTab = 0
        }) {
            Image(systemName: "xmark")
                .font(.title2)
                .foregroundColor(.black)
        }
    }
    
    private var publishButton: some View {
        Button(action: { viewModel.showSecondView = true }) {
            Text("发布")
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .foregroundColor(.white)
                .background(Color.black)
                .cornerRadius(25)
        }
    }
    

    
    private var contentInputSection: some View {
        CustomTextView(
            text: $viewModel.content,
            selectedRange: $viewModel.contentSelectedRange,
            focusedField: $viewModel.focusedField
        )
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(minHeight: 300)
        .padding(.horizontal)
        .onChange(of: viewModel.content) {
            viewModel.checkForHashtagTrigger(in: viewModel.content)
        }
    }
    private var tagsSection: some View {
        FlowLayout(spacing: 8) {
               ForEach(viewModel.selectedTags, id: \.self) { tag in
                   tagView(tag)
               }
           }
           .padding(.horizontal)
    }
    
    private var toolbarSection: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 24) {
                Button(action: { viewModel.isShowingImagePicker = true }) {
                                  Image(systemName: "photo")
                                      .foregroundColor(.black)
                              }
                
                Button(action: { viewModel.isShowingEmojiPicker = true }) {
                               Image(systemName: "face.smiling")
                                   .foregroundColor(.black)
                           }
                
                Button(action: {
                    viewModel.isShowingHashtagSelector.toggle() // 使用 toggle() 来切换状态
                }) {
                    Image(systemName: "number")
                        .foregroundColor(viewModel.isShowingHashtagSelector ? .blue : .black) // 可选：添加选中状态的颜色
                }
            
               
                
                Spacer()
                // 添加键盘收起按钮
                             Button(action: dismissKeyboard) {
                                 Image(systemName: "keyboard.chevron.compact.down.fill")
                                     .foregroundColor(.black)
                             }
                Text("\(viewModel.characterCount)/\(Layout.maxCharacterCount)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .frame(height: Layout.toolbarHeight)
            .background(Color(UIColor.systemBackground))
        }
    }
    
    private func tagView(_ tag: String) -> some View {
        HStack(spacing: 4) {
            Text(tag)
                .foregroundColor(.blue)
            Button(action: {
                viewModel.removeTag(tag)
            }) {
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
// 图片展示组件
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


// MARK: - Preview
struct PostInputView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PostInputView(
                isPresented: .constant(true),
                selectedTab: .constant(0)
            )
        }
    }
}


