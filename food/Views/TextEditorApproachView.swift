import SwiftUI

struct TextEditorApproachView: View {
    
    @State private var text: String? = nil // Initializing to nil
    
    let placeholder = "Enter Text Here"
    
    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                // Placeholder text, only visible when text is empty
                if text == nil || text!.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.black) // Light color for the placeholder
                        .padding(EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4))
                }
                
                TextEditor(text: Binding($text, replacingNilWith: ""))
                    .frame(minHeight: 30, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4))
                    .background(Color.clear) // Ensure the TextEditor has no background
            }
        }
        .padding() // Optional padding around the entire view
    }
}

struct TextEditorApproachView_Previews: PreviewProvider {
    static var previews: some View {
        TextEditorApproachView() // Preview works with default nil text
    }
}

public extension Binding where Value: Equatable {
    
    init(_ source: Binding<Value?>, replacingNilWith nilProxy: Value) {
        self.init(
            get: { source.wrappedValue ?? nilProxy },
            set: { newValue in
                if newValue == nilProxy {
                    source.wrappedValue = nil
                } else {
                    source.wrappedValue = newValue
                }
            }
        )
    }
}
