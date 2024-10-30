import SwiftUI

// MARK: - ViewModel
final class SearchAndFilterViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var isShowingFilter = false
    
    // 防抖动搜索
    private var searchTask: DispatchWorkItem?
    
    func performSearch() {
        searchTask?.cancel()
        
        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            // 在这里执行实际的搜索逻辑
            print("Searching for: \(self.searchText)")
        }
        
        searchTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
    }
}

// MARK: - Main View
struct SearchAndFilterView: View {
    @StateObject private var viewModel = SearchAndFilterViewModel()
    @Binding var search: String
    
    var body: some View {
        searchContent
            .onChange(of: search) { 
                viewModel.performSearch()
            }
    }
    
    private var searchContent: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                SearchTextField(
                    text: $search,
                    placeholder: "请输入要查找的话题，标签等..."
                )
                
                FilterButton(isShowingFilter: $viewModel.isShowingFilter)
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $viewModel.isShowingFilter) {
            SearchFilterView(showFilterView: $viewModel.isShowingFilter)
        }
    }
}

// MARK: - Supporting Views
struct SearchTextField: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .padding(.vertical, 2)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.black)
                .accentColor(.gray)
                .textInputAutocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.white))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
        }
    }
}

struct FilterButton: View {
    @Binding var isShowingFilter: Bool
    
    var body: some View {
        Button(action: { isShowingFilter.toggle() }) {
            Image(systemName: "slider.horizontal.3")
                .foregroundColor(.black)
                .frame(width: 20, height: 20)
                .padding(8)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(UIColor.white))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                }
        }
    }
}

// MARK: - Previews
struct SearchAndFilterView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var search = ""
        
        var body: some View {
            SearchAndFilterView(search: $search)
        }
    }
    
    static var previews: some View {
        Group {
            PreviewWrapper()
                .previewDisplayName("Light Mode")
            
            PreviewWrapper()
                .previewLayout(.fixed(width: 375, height: 60))
                .previewDisplayName("iPhone SE")
        }
    }
}
