
import SwiftUI

struct SearchAndFilterView: View {
    @Binding var search: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Search Box
            HStack {
                Image(uiImage: #imageLiteral(resourceName: "search"))
                    .foregroundColor(.gray) // Change icon color if needed
                
                TextField("Search for recipes", text: $search)
                    .padding(4)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.black)
                    .accentColor(.gray) // Customize the cursor color
            }
            .padding(10)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // Filter Button
            Image(uiImage: #imageLiteral(resourceName: "filter"))
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                .onTapGesture {
                    // Add your filter logic here
                }
        }
        .padding()
    }
}
struct SearchAndFilterView_Previews: PreviewProvider {
    @State static var search = "请输入要查找的话题，标签等..."
    
    static var previews: some View {
        SearchAndFilterView(search: $search)
    }
}
