import SwiftUI
import PhotosUI

// PHPickerViewController的包装器，允许在SwiftUI中使用
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images // 只显示图片
        config.selectionLimit = 1 // 选择一张图片

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
}

struct ProfileEditorView: View {
    @Environment(\.presentationMode) var presentationMode // 用于后退功能
    @State private var nickname: String = "东京 it 小白"
    @State private var bio: String = "美妙的生活由此开始~"
    @State private var idNumber: String = "178385"
    @State private var selectedGender = "男" // 默认性别
    let genders = ["男", "女", "其他"] // 性别选项
    
    @State private var showImagePicker = false
    @State private var showImagePickerOptions = false
    @State private var selectedImage: UIImage? // 保存用户选择的头像

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 顶部头像和相机按钮
                    VStack {
                        ZStack {
                            // 如果用户选择了图片，则显示该图片，否则显示默认图标
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.black) // 小人图标为黑色
                                    .background(
                                        Circle()
                                            .fill(Color.white) // 圆形背景为白色
                                            .frame(width: 100, height: 100)
                                    )
                                    .clipShape(Circle()) // 确保是圆形
                            }
                        }
                        
                        // 点击相机按钮显示选择选项
                        Button(action: {
                            showImagePickerOptions = true
                        }) {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.blue)
                                .padding(8)
                                .background(Color.white)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                        }
                        .offset(x: 30, y: -30) // 相机按钮的位置
                        .confirmationDialog("选择头像", isPresented: $showImagePickerOptions, titleVisibility: .visible) {
                            Button("从相册选择") {
                                showImagePicker = true
                            }
                            Button("取消", role: .cancel) {}
                        }

                        // ID 紧贴头像下方显示
                        Text("ID: \(idNumber)")
                            .font(.footnote) // 小字体
                            .foregroundColor(.gray)
                            .padding(.top, 4) // 让 ID 紧贴头像
                    }
                    .padding(.top, 40)
                    
                    VStack(alignment: .leading, spacing: 30) {
                        // 昵称
                        VStack(alignment: .leading) {
                            Text("昵称")
                                .font(.headline)
                            InputField(placeholder: "请输入昵称", text: $nickname, systemImage: "", isSecure: false)
                        }
                        
                        // 性别选择器
                        VStack(alignment: .leading) {
                            Text("性别")
                                .font(.headline)
                            HStack {
                                Picker("性别", selection: $selectedGender) {
                                    ForEach(genders, id: \.self) { gender in
                                        Text(gender)
                                            .tag(gender)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle()) // 使用分段选择器样式
                                .padding(.vertical, 12)
                            }
                            .padding(.horizontal)
                            .overlay(Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.5)).padding(.horizontal, 10), alignment: .bottom)
                        }
                        
                        // 个性签名
                        VStack(alignment: .leading) {
                            Text("个性签名")
                                .font(.headline)
                            InputField(placeholder: "请输入个性签名", text: $bio, systemImage: "", isSecure: false)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            Spacer()
            
            // 固定在底部的保存按钮
            Button(action: {
                // 保存个人信息的操作
            }) {
                Text("保存")
                    .font(.system(size: 18, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.black)
                    .cornerRadius(25)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .navigationTitle("个人信息")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
            }
        )
        // 弹出图片选择器
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
}

struct ProfileEditorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileEditorView()
        }
    }
}
