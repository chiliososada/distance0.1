import SwiftUI

struct SearchFilterView: View {
    @Binding var showFilterView: Bool
    @State private var selectedDistance: Double = 50
    @State private var selectedTimeIndex = 0
    @State private var selectedParticipants = 10

    // Language and Category options
    @State private var selectedLanguages: [String] = []
    @State private var selectedCategories: [String] = []  // For multi-selection in categories
    let languages = ["日语", "英语", "汉语", "越南语"]
    let categories = ["个人", "商家", "官方"]  // Removed "全部"

    let times = ["过去1天", "过去1周", "过去1月", "全部"]

    var body: some View {
        VStack {
            // Header with Filter title and Reset button
            HStack {
                Button(action: {
                    showFilterView = false  // Close filter view
                }) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(.black)
                }
                Spacer()
                Text("筛选条件")
                    .font(.headline)
                Spacer()
                Button(action: {
                    // Reset action to clear all filters
                    resetFilters()
                }) {
                    Text("重置")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            }
            .padding([.leading, .trailing], 16)
            .padding(.top, 16)

            Divider()

            ScrollView {
                // Distance Filter
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("距离 (km)")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Spacer()
                        Text("\(Int(selectedDistance)) km")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Slider(value: $selectedDistance, in: 0...100)
                        .accentColor(.blue)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)

                // Time Filter
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("发布时间")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Spacer()
                        Text(times[selectedTimeIndex])
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Picker(selection: $selectedTimeIndex, label: Text("")) {
                        ForEach(times.indices, id: \.self) { index in
                            Text(times[index]).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                // Category Filter (种类) using LazyVGrid for multi-selection
                VStack(alignment: .leading, spacing: 10) {
                    Text("种类")
                        .font(.subheadline)
                        .foregroundColor(.black)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                        ForEach(categories, id: \.self) { category in
                            HStack {
                                Text(category)
                                    .font(.subheadline)
                                    .foregroundColor(selectedCategories.contains(category) ? .white : .black)
                                    .padding(10)
                                    .background(selectedCategories.contains(category) ? Color.blue : Color.gray.opacity(0.2))
                                    .cornerRadius(16)
                                    .onTapGesture {
                                        toggleCategorySelection(category)
                                    }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)

             
                // Language Filter (语言) using LazyVGrid
                VStack(alignment: .leading, spacing: 10) {
                    Text("语言")
                        .font(.subheadline)
                        .foregroundColor(.black)

                    HStack {  // 使用 HStack 来确保语言部分在一行显示，并且占满宽度
                        ForEach(languages, id: \.self) { language in
                            HStack {
                                Text(language)
                                    .font(.subheadline)
                                    .foregroundColor(selectedLanguages.contains(language) ? .white : .black)
                                    .padding(10)
                                    .background(selectedLanguages.contains(language) ? Color.blue : Color.gray.opacity(0.2))
                                    .cornerRadius(16)
                                    .onTapGesture {
                                        toggleLanguageSelection(language)
                                    }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)  // 设置最大宽度，确保背景与其他条件对齐
                    .padding(.vertical, 10)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)

               

                // Participants Filter (最少参与人数)
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("最少参与人数")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Spacer()
                        Text("\(selectedParticipants) 人")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Stepper(value: $selectedParticipants, in: 1...1000, step: 1) {
                        Text("")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }

            // Apply Filter Button
            VStack(spacing: 16) {
                Button(action: {
                    showFilterView = false  // Apply filter and close view
                }) {
                    Text("应用筛选")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 16)
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))  // Background color
        .frame(maxHeight: UIScreen.main.bounds.height * 0.85)  // Height constraint
    }

    // Toggle category selection for the checkboxes
    private func toggleCategorySelection(_ category: String) {
        if let index = selectedCategories.firstIndex(of: category) {
            selectedCategories.remove(at: index)
        } else {
            selectedCategories.append(category)
        }
    }

    // Toggle language selection for the checkboxes
    private func toggleLanguageSelection(_ language: String) {
        if let index = selectedLanguages.firstIndex(of: language) {
            selectedLanguages.remove(at: index)
        } else {
            selectedLanguages.append(language)
        }
    }

    // Reset filters to initial state
    private func resetFilters() {
        selectedDistance = 50
        selectedTimeIndex = 0
        selectedParticipants = 10
        selectedLanguages.removeAll()
        selectedCategories.removeAll()
    }
}

// MARK: - Preview
struct SearchFilterView_Previews: PreviewProvider {
    @State static var showFilterView = true

    static var previews: some View {
        SearchFilterView(showFilterView: $showFilterView)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
