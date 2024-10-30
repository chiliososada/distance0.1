//
//  RecipeDetailView.swift
//  food
//
//  Created by toyousoft on 2024/10/30.
//

import SwiftUI


// MARK: - RecipeDetailView Optimizations
struct RecipeDetailView: View {
    let recipe: RecommendedRecipe
    @State private var currentImageIndex = 0
    @State private var isPressed = false
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var tabBarManager: TabBarManager
    var body: some View {
        ZStack(alignment: .top) {
            // Content
            ScrollView {
                VStack(spacing: 0) {
                    // Image Carousel without navigation buttons
                    ImageCarouselContent(
                        images: recipe.imageNames,
                        currentIndex: $currentImageIndex
                    )
                    
                    DetailContent(recipe: recipe, currentImageIndex: $currentImageIndex)
                }
            }
            
            // Custom Navigation Bar
            CustomNavigationBar(
                leadingButton: {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.black)
                            .padding(9)
                            .background(Color.white)
                            .cornerRadius(8)
                           
                    }
                },
                trailingButton: {
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                            .foregroundColor(.black)
                            .padding(9)
                            .background(Color.white)
                            .cornerRadius(8)
                          
                    }
                }
            )
            
            // Floating Join Button
            FloatingJoinButton(isPressed: $isPressed)
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
        .onAppear { tabBarManager.isViewTabBarHidden = true }
        .onDisappear { tabBarManager.isViewTabBarHidden = false }
    }
}
struct ImageCarouselContent: View {
    let images: [String]
    @Binding var currentIndex: Int

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(0..<images.count, id: \.self) { index in
                Image(images[index])
                    .resizable()
                    .scaledToFit() // 保持图片比例
                    .frame(width: UIScreen.main.bounds.width) // 适配屏幕宽度
                    .clipped() // 防止溢出
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // 显示分页指示器
        .frame(height: 450) // 调整高度适应大部分图片比例
    }
}


// MARK: - DetailContent
struct DetailContent: View {
    let recipe: RecommendedRecipe
    @Binding var currentImageIndex: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Page Indicator
            HStack {
                Spacer()
                ForEach(0..<recipe.imageNames.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentImageIndex ? Color.black : Color.gray)
                        .frame(width: 8, height: 8)
                        .opacity(index == currentImageIndex ? 1 : 0.3)
                }
                Spacer()
            }
            .padding(.vertical, 8)
            
            // Author Info
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Image("sample2")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                        Text(recipe.authorName)
                            .foregroundColor(.blue)
                            .font(.subheadline)
                        Spacer()
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                            Text(recipe.remainingDays)
                                .lineLimit(1)
                        }
                    }
                    
                    // Title
                    Text(recipe.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Tags
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(recipe.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(6)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    
                    // Location
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.gray)
                        Text(recipe.location)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "star.fill")
                                .font(.title3)
                                .foregroundColor(.yellow)
                                .padding(6)
                                .background(Color.white)
                                .cornerRadius(6)
                                
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.horizontal)
            
            // Details Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Details")
                    .font(.headline)
                    .padding(.horizontal)
                
                HStack(spacing: 10) {
                    DetailItem(icon: "calendar", text: recipe.publishDate)
                    DetailItem(icon: "person.2.fill", text: recipe.joinedCount)
                }
                .padding(.horizontal)
                
                Text("Content")
                    .font(.headline)
                    .padding(.horizontal)
                
                Text(recipe.content)
                    .font(.body)
                    .padding(.horizontal)
            }
        }
    }
}

struct DetailItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(text)
                .lineLimit(1)
        }
        .padding(8)
        .background(Color.blue.opacity(0.2))
        .cornerRadius(10)
        .frame(minWidth: 80)
    }
}

// MARK: - FloatingJoinButton
struct FloatingJoinButton: View {
    @Binding var isPressed: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                Button(action: {}) {
                    Text("Join")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Circle().fill(Color.black))
                        .opacity(0.8)
                }
                .position(x: geometry.size.width-60, y: geometry.size.height - 80)
            }
        }
    }
}


// MARK: - Previews
struct RecipeDetailView_Previews: PreviewProvider {
    static var previewRecipe = RecommendedRecipe(
        imageName: "sample1",
        title: "有一起打球的的吗",
        imageNames: ["sample1", "reco_2", "reco_3"],
        authorName: "劉子源",
        location: "東京都 葛飾区 立石",
        tags: ["娱乐", "运动", "篮球"],
        participantsCount: 99,
        postedTime: "10 mins",
        distance: 300,
        isLiked: false,
        avatarImage: "sample2",
        remainingDays: "3 days",
        publishDate: "2024-10-01",
        joinedCount: "75＋",
        content: "今天早上我有个计划，就是去入管局办理一些手续。最近一直忙着工作，所以这件事拖了好久。想着今天正好有空，赶紧去处理一下。"
    )
    
    static var previews: some View {
        // 亮色模式预览
        RecipeDetailView(recipe: previewRecipe)
            .environmentObject(TabBarManager())
            .previewDisplayName("Light Mode")

        // iPhone SE 预览
        RecipeDetailView(recipe: previewRecipe)
            .environmentObject(TabBarManager())
            .previewDevice("iPhone SE (3rd generation)")
            .previewDisplayName("iPhone SE")
    }
}
