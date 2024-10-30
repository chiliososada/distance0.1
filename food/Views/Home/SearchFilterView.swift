import SwiftUI

// MARK: - ViewModel
final class SearchFilterViewModel: ObservableObject {
    @Published var selectedDistance: Double = 50
    @Published var selectedTimeIndex = 0
   
    @Published var selectedLanguages: Set<String> = []  // 使用 Set 优化查找性能
    @Published var selectedCategories: Set<String> = []
    
    let languages = ["日语", "英语", "汉语", "越南语"]
    let categories = ["个人", "商家", "官方"]
    let times = ["过去1天", "过去1周", "过去1月", "全部"]
    
    func toggleSelection(for item: String, in set: inout Set<String>) {
        if set.contains(item) {
            set.remove(item)
        } else {
            set.insert(item)
        }
    }
    
    func resetFilters() {
        selectedDistance = 50
        selectedTimeIndex = 0
        
        selectedLanguages.removeAll()
        selectedCategories.removeAll()
    }
}

// MARK: - Main View
struct SearchFilterView: View {
    @StateObject private var viewModel = SearchFilterViewModel()
    @Binding var showFilterView: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                showFilterView: $showFilterView,
                onReset: viewModel.resetFilters
            )
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    Spacer()
                    // Distance Filter
                    FilterSection(title: "距离 (km)", value: "\(Int(viewModel.selectedDistance)) km") {
                        DistanceSlider(value: $viewModel.selectedDistance)
                    }
                    
                    // Time Filter
                    FilterSection(title: "发布时间", value: viewModel.times[viewModel.selectedTimeIndex]) {
                        TimePickerView(
                            selectedIndex: $viewModel.selectedTimeIndex,
                            times: viewModel.times
                        )
                    }
                    
                    // Category Filter
                    FilterSection(title: "种类") {
                        CategoryGridView(
                            categories: viewModel.categories,
                            selectedCategories: $viewModel.selectedCategories
                        )
                    }
                    
                    // Language Filter
                    FilterSection(title: "语言") {
                        LanguageSelectionView(
                            languages: viewModel.languages,
                            selectedLanguages: $viewModel.selectedLanguages
                        )
                    }
                    
                    // Participants Filter
                  
                }
                .padding(.horizontal)
            }
            
            ApplyButton(showFilterView: $showFilterView)
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .frame(maxHeight: UIScreen.main.bounds.height * 0.85)
    }
}

// MARK: - Supporting Views
struct HeaderView: View {
    @Binding var showFilterView: Bool
    let onReset: () -> Void
    
    var body: some View {
        HStack {
            Button(action: { showFilterView = false }) {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .foregroundColor(.black)
            }
            Spacer()
            Text("筛选条件")
                .font(.headline)
            Spacer()
            Button(action: onReset) {
                Text("重置")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
        }
        .padding([.horizontal, .top], 16)
        .background(Color.white)
        Divider()
    }
}

struct FilterSection<Content: View>: View {
    let title: String
    var value: String? = nil
    let content: Content
    
    init(title: String, value: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.value = value
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.black)
                Spacer()
                if let value = value {
                    Text(value)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            content
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct DistanceSlider: View {
    @Binding var value: Double
    
    var body: some View {
        Slider(value: $value, in: 0...100)
            .accentColor(.black)
    }
}

struct TimePickerView: View {
    @Binding var selectedIndex: Int
    let times: [String]
    
    var body: some View {
        Picker("", selection: $selectedIndex) {
            ForEach(times.indices, id: \.self) { index in
                Text(times[index]).tag(index)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

struct CategoryGridView: View {
    let categories: [String]
    @Binding var selectedCategories: Set<String>
    
    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
            spacing: 10
        ) {
            ForEach(categories, id: \.self) { category in
                SelectionButton(
                    title: category,
                    isSelected: selectedCategories.contains(category)
                ) {
                    if selectedCategories.contains(category) {
                        selectedCategories.remove(category)
                    } else {
                        selectedCategories.insert(category)
                    }
                }
            }
        }
    }
}

struct LanguageSelectionView: View {
    let languages: [String]
    @Binding var selectedLanguages: Set<String>
    
    var body: some View {
        HStack {
            ForEach(languages, id: \.self) { language in
                SelectionButton(
                    title: language,
                    isSelected: selectedLanguages.contains(language)
                ) {
                    if selectedLanguages.contains(language) {
                        selectedLanguages.remove(language)
                    } else {
                        selectedLanguages.insert(language)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }
}

struct SelectionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Text(title)
            .font(.subheadline)
            .foregroundColor(isSelected ? .white : .black)
            .padding(10)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .cornerRadius(16)
            .onTapGesture(perform: action)
    }
}



struct ApplyButton: View {
    @Binding var showFilterView: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: { showFilterView = false }) {
                Text("应用筛选")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 16)
        .background(Color.white)
    }
}

// MARK: - Preview
struct SearchFilterView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SearchFilterView(showFilterView: .constant(true))
                .previewDisplayName("Light Mode")
            
            SearchFilterView(showFilterView: .constant(true))
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
