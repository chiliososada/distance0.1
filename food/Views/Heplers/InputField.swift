import SwiftUI

// MARK: - Constants
private enum Layout {
    static let fontSize: CGFloat = 18
    static let iconSize: CGFloat = 20
    static let verticalPadding: CGFloat = 12
    static let horizontalPadding: CGFloat = 16
    static let borderHeight: CGFloat = 1
    static let borderPadding: CGFloat = 10
}

// MARK: - Input Field Configuration
struct InputFieldConfiguration {
    var placeholder: String
    var systemImage: String
    var isSecure: Bool
    var keyboardType: UIKeyboardType
    var textContentType: UITextContentType?
    var borderColor: Color
    
    static func standard(
        placeholder: String,
        systemImage: String = "",
        isSecure: Bool = false
    ) -> InputFieldConfiguration {
        InputFieldConfiguration(
            placeholder: placeholder,
            systemImage: systemImage,
            isSecure: isSecure,
            keyboardType: .default,
            textContentType: nil,
            borderColor: .gray.opacity(0.5)
        )
    }
    
    static func email(placeholder: String = "邮箱") -> InputFieldConfiguration {
        InputFieldConfiguration(
            placeholder: placeholder,
            systemImage: "",
            isSecure: false,
            keyboardType: .emailAddress,
            textContentType: .emailAddress,
            borderColor: .gray.opacity(0.5)
        )
    }
    
    static func password(placeholder: String = "密码") -> InputFieldConfiguration {
        InputFieldConfiguration(
            placeholder: placeholder,
            systemImage: "",
            isSecure: true,
            keyboardType: .default,
            textContentType: .password,
            borderColor: .gray.opacity(0.5)
        )
    }
}

// MARK: - Input Field Component
struct InputField: View {
    let configuration: InputFieldConfiguration
    @Binding var text: String
    var onEditingChanged: ((Bool) -> Void)?
    var onCommit: (() -> Void)?
    
    init(
        configuration: InputFieldConfiguration = .standard(placeholder: ""),
        text: Binding<String>,
        onEditingChanged: ((Bool) -> Void)? = nil,
        onCommit: (() -> Void)? = nil
    ) {
        self.configuration = configuration
        self._text = text
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }
    
    // 便利初始化器
    init(
        placeholder: String,
        text: Binding<String>,
        systemImage: String = "",
        isSecure: Bool = false
    ) {
        self.init(
            configuration: .standard(
                placeholder: placeholder,
                systemImage: systemImage,
                isSecure: isSecure
            ),
            text: text
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: Layout.horizontalPadding) {
                textField
                iconView
            }
            .padding(.horizontal, Layout.horizontalPadding)
            .padding(.vertical, Layout.verticalPadding)
            
            borderView
        }
    }
    
    @ViewBuilder
    private var textField: some View {
        Group {
            if configuration.isSecure {
                SecureField(configuration.placeholder, text: $text) {
                    onCommit?()
                }
            } else {
                TextField(configuration.placeholder, text: $text) { isEditing in
                    onEditingChanged?(isEditing)
                } onCommit: {
                    onCommit?()
                }
            }
        }
        .font(.system(size: Layout.fontSize))
        .foregroundColor(.black)
        .keyboardType(configuration.keyboardType)
        .textContentType(configuration.textContentType)
        .autocapitalization(.none)
        .disableAutocorrection(true)
    }
    
    @ViewBuilder
    private var iconView: some View {
        if !configuration.systemImage.isEmpty {
            Image(systemName: configuration.systemImage)
                .foregroundColor(.black)
                .font(.system(size: Layout.iconSize))
                .frame(width: Layout.iconSize, height: Layout.iconSize)
        }
    }
    
    private var borderView: some View {
        Rectangle()
            .frame(height: Layout.borderHeight)
            .foregroundColor(configuration.borderColor)
            .padding(.horizontal, Layout.borderPadding)
    }
}

// MARK: - Input Field Modifiers
extension InputField {
    func onTextChange(_ action: @escaping (String) -> Void) -> some View {
        if #available(iOS 17.0, *) {
            return onChange(of: text) { oldValue, newValue in
                action(newValue)
            }
        } else {
            return onChange(of: text) { newValue in
                action(newValue)
            }
        }
    }
}


// MARK: - Preview
struct InputField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // 标准输入框
            InputField(
                placeholder: "用户名",
                text: .constant(""),
                systemImage: "person"
            )
            
            // 邮箱输入框
            InputField(
                configuration: .email(),
                text: .constant("")
            )
            
            // 密码输入框
            InputField(
                configuration: .password(),
                text: .constant("")
            )
            
            // 带验证图标的输入框
            InputField(
                placeholder: "验证完成",
                text: .constant("已验证"),
                systemImage: "checkmark.circle.fill"
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
