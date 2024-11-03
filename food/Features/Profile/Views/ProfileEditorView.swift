import SwiftUI
import PhotosUI



// 优化后的图片选择器
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }
            
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                DispatchQueue.main.async {
                    self?.parent.selectedImage = image as? UIImage
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
}

// 头像组件
struct ProfileAvatarView: View {
    let image: UIImage?
    let action: () -> Void
    
    var body: some View {
        VStack {
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.black)
                        .background(Circle().fill(Color.white))
                        .clipShape(Circle())
                }
                
                cameraButton
            }
        }
    }
    
    private var cameraButton: some View {
        Button(action: action) {
            Image(systemName: "camera.fill")
                .foregroundColor(.blue)
                .padding(8)
                .background(Color.white)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
        }
        .offset(x: 30, y: 30)
    }
}

// 信息输入字段组件
struct ProfileField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            InputField(
                placeholder: placeholder,
                text: $text,
                systemImage: "",
                isSecure: false
            )
        }
    }
}



struct ProfileEditorView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var profileState = ProfileEditState()
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    avatarSection
                    infoSection
                }
            }
        }
        .navigationTitle("个人信息")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton, trailing: saveButton)
        .sheet(isPresented: $profileState.showImagePicker) {
            ImagePicker(selectedImage: $profileState.selectedImage)
        }
        .sheet(isPresented: $profileState.isShowingDatePicker) {
                    datePickerSheet
                }
    }
    
    private var avatarSection: some View {
        VStack {
            ProfileAvatarView(
                image: profileState.selectedImage,
                action: { profileState.showImagePickerOptions = true }
            )
            
            Text("ID: \(profileState.idNumber)")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.top, 4)
        }
        .padding(.top, 40)
        .confirmationDialog(
            "选择头像",
            isPresented: $profileState.showImagePickerOptions,
            titleVisibility: .visible
        ) {
            Button("从相册选择") {
                profileState.showImagePicker = true
            }
            Button("取消", role: .cancel) {}
        }
    }
    // 添加出生日期选择器组件
    private var birthDateSelector: some View {
        VStack(alignment: .leading) {
            Text("出生年月")
                .font(.headline)
            
            Button(action: {
                profileState.isShowingDatePicker = true
            }) {
                HStack {
                    Text(profileState.birthDate, style: .date)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                )
            }
            .buttonStyle(PlainButtonStyle()) // 去掉默认的按钮样式
        }
    }
    private var datePickerSheet: some View {
        VStack {
            HStack {
                Button("取消") {
                    profileState.isShowingDatePicker = false
                }
                Spacer()
                Text("选择你的生日")
                    .font(.headline)
                Spacer()
                Button("保存") {
                    profileState.isShowingDatePicker = false
                }
            }
            .padding()

            DatePicker(
                "",
                selection: $profileState.birthDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .environment(\.locale, Locale(identifier: "zh_CN")) // 强制为中文显示
            .padding()
        }
    }
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 30) {
            ProfileField(
                title: "昵称",
                text: $profileState.nickname,
                placeholder: "请输入昵称"
            )
            
            genderSelector
            birthDateSelector
            ProfileField(
                title: "个性签名",
                text: $profileState.bio,
                placeholder: "请输入个性签名"
            )
        }
        .padding(.horizontal, 20)
    }
    
    private var genderSelector: some View {
        VStack(alignment: .leading) {
            Text("性别")
                .font(.headline)
            Picker("性别", selection: $profileState.selectedGender) {
                ForEach(profileState.genders, id: \.self) { gender in
                    Text(gender).tag(gender)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.vertical, 12)
            .padding(.horizontal)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.horizontal, 10),
                alignment: .bottom
            )
        }
    }
    
    private var saveButton: some View {
        Button(action: handleSave) {
            Text("保存")
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .foregroundColor(.white)
                .background(profileState.hasChanges ? Color.black : Color.gray)
                .cornerRadius(25)
        }
        .disabled(!profileState.hasChanges)
    }
    
    private var backButton: some View {
        Button(action: { presentationMode.wrappedValue.dismiss() }) {
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.black)
        }
    }
    
    private func handleSave() {
        // 处理保存逻辑
    }
}

struct ProfileEditorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileEditorView()
        }
    }
}
